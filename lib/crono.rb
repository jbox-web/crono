# frozen_string_literal: true

# require external dependencies
require 'active_record'
require 'active_support/all'

# require internal dependencies
require_relative 'crono/util'
require_relative 'crono/config'
require_relative 'crono/cronotab'
require_relative 'crono/launcher'
require_relative 'crono/performer_proxy'
require_relative 'crono/scheduler'
require_relative 'crono/version'

module Crono
  require_relative 'crono/engine' if defined?(Rails)

  mattr_accessor :logger
  mattr_accessor :scheduler

  def self.perform(performer, *job_args)
    PerformerProxy.new(performer, Crono.scheduler, job_args)
  end

  def self.start_watchdog
    usec = Integer(ENV["WATCHDOG_USEC"])
    return Crono.logger.error("systemd Watchdog too fast: " + usec) if usec < 1_000_000

    sec_f = usec / 1_000_000.0
    # "It is recommended that a daemon sends a keep-alive notification message
    # to the service manager every half of the time returned here."
    ping_f = sec_f / 2
    Crono.logger.info "Pinging systemd watchdog every #{ping_f.round(1)} sec"
    Thread.new do
      loop do
        sleep ping_f
        Crono::SdNotify.watchdog
      end
    end
  end
end
