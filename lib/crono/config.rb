# frozen_string_literal: true

module Crono
  # Crono::Config stores Crono configuration
  class Config
    CRONOTAB = 'config/cronotab.rb'

    attr_accessor :cronotab,
                  :environment,
                  :verbose,
                  :lifecycle_events,
                  :check_port

    def initialize
      self.cronotab = CRONOTAB
      self.environment = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      self.verbose = false
      self.lifecycle_events = {
        startup: [],
        shutdown: [],
      }
      self.check_port = 9261
    end

    def on(event, &block)
      raise ArgumentError, "Symbols only please: #{event}" unless event.is_a?(Symbol)
      raise ArgumentError, "Invalid event name: #{event}" unless lifecycle_events.key?(event)

      lifecycle_events[event] << block
    end
  end
end
