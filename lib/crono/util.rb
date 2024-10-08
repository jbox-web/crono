# frozen_string_literal: true

module Crono
  module Util

    # Taken from Sidekiq
    # See: https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/util.rb#L52
    def fire_event(event, options = {}) # rubocop:disable Metrics/MethodLength
      reverse = options[:reverse]
      reraise = options[:reraise]

      arr = config.lifecycle_events[event]
      arr.reverse! if reverse
      arr.each do |block|
        begin # rubocop:disable Style/RedundantBegin
          block.call
        rescue ex => _e
          raise ex if reraise
        end
      end
    end


    def safe_thread(name)
      Thread.new do
        Thread.current.name = name
        yield
      end
    end


    def logger
      Crono.logger
    end


    def logfile=(logfile)
      Crono.logger = Logger.new(logfile)
      Crono.logger.level = ::Logger::INFO
    end

  end
end
