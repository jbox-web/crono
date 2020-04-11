# frozen_string_literal: true

# require external dependencies
require 'active_support/all'
require 'zeitwerk'

# load lib files
loader = Zeitwerk::Loader.for_gem
generators = "#{__dir__}/generators"
loader.ignore(generators)
loader.inflector.inflect(
  'cli' => 'CLI'
)
loader.setup

module Crono
  require 'crono/railtie' if defined?(Rails)

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
