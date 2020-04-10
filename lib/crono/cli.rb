# frozen_string_literal: true

Thread.abort_on_exception = true

# require external dependencies
require 'optparse'

# require ourself
require 'crono'

module Crono
  # Crono::CLI - The main class for the crono daemon exacutable `bin/crono`
  class CLI
    include Singleton
    include Logging

    PROCTITLES = [
      proc { 'crono' },
      proc { Crono::VERSION::STRING },
      proc { |me, data| "[#{data['jobs']} jobs in queue]" },
    ]

    attr_accessor :config

    def initialize
      self.config = Config.new
      self.logfile = STDOUT
      Crono.scheduler = Scheduler.new
    end


    def run
      parse_options(ARGV)

      load_rails

      Cronotab.process(File.expand_path(config.cronotab))

      print_banner

      unless have_jobs?
        logger.error "You have no jobs in you cronotab file #{config.cronotab}"
        return
      end

      start_working_loop
    end


    private


      def parse_options(argv)
        @argv = OptionParser.new do |opts|
          opts.banner = 'Usage: crono [options]'

          opts.on('-C', '--cronotab PATH', "Path to cronotab file (Default: #{config.cronotab})") do |cronotab|
            config.cronotab = cronotab
          end

          opts.on '-e', '--environment ENV', "Application environment (Default: #{config.environment})" do |env|
            config.environment = env
          end
        end.parse!(argv)
      end


      def load_rails
        ENV['RACK_ENV']  = 'none'
        ENV['RAILS_ENV'] = config.environment
        require 'rails'
        require File.expand_path('config/environment.rb')
        ::Rails.application.eager_load!
      end


      def print_banner
        logger.info "Loading Crono #{Crono::VERSION::STRING}"
        logger.info "Running in #{RUBY_DESCRIPTION}"

        logger.info 'Jobs:'
        Crono.scheduler.jobs.each do |job|
          logger.info "'#{job.performer}' with rule '#{job.period.description}'"\
                      " next time will perform at #{job.next}"
        end
      end


      def have_jobs?
        Crono.scheduler.jobs.present?
      end


      def start_working_loop
        fire_event(:startup, reraise: true)
        loop do
          next_time, jobs = Crono.scheduler.next_jobs
          now = Time.zone.now
          heartbeat(jobs.size)
          sleep(next_time - now) if next_time > now
          jobs.each(&:perform)
        end
      end


      # Taken from Sidekiq
      # See: https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/util.rb#L52
      def fire_event(event, options = {})
        reverse = options[:reverse]
        reraise = options[:reraise]

        arr = config.lifecycle_events[event]
        arr.reverse! if reverse
        arr.each do |block|
          begin
            block.call
          rescue ex => e
            raise ex if reraise
          end
        end
      end


      def heartbeat(jobs)
        data = { 'jobs' => jobs }
        $0 = PROCTITLES.map { |proc| proc.call(self, data) }.compact.join(' ')
      end


      def root
        @root ||= rails_root_defined? ? ::Rails.root : DIR_PWD
      end


      def rails_root_defined?
        defined?(::Rails.root)
      end

  end
end
