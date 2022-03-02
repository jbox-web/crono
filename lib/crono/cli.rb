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
    include Util

    attr_accessor :config
    attr_accessor :launcher

    def initialize
      self.config = Config.new
      self.logfile = STDOUT
      Crono.scheduler = Scheduler.new
    end


    def parse(args = ARGV)
      parse_options(args)
      initialize_logger
    end


    def run
      self_read, self_write = IO.pipe

      sigs = %w[INT TERM]
      sigs.each do |sig|
        trap sig do
          self_write.puts(sig)
        end
      rescue ArgumentError
        puts "Signal #{sig} not supported"
      end

      # <dirty_patch>
      # Require those files manually since they won't be loaded by Rails
      # when running *bin/crono* command on app side
      # </dirty_patch>
      require_relative '../../app/models/crono/application_record'
      require_relative '../../app/models/crono/crono_job'

      load_rails

      Cronotab.process(File.expand_path(config.cronotab))

      unless have_jobs?
        logger.error "You have no jobs in you cronotab file #{config.cronotab}"
        return
      end

      print_banner

      fire_event(:startup, reraise: true)

      launch(self_read)
    end


    private


      def parse_options(args)
        parser = OptionParser.new do |opts|
          opts.banner = 'Usage: crono [options]'

          opts.on('-C', '--cronotab PATH', "Path to cronotab file (Default: #{config.cronotab})") do |cronotab|
            config.cronotab = cronotab
          end

          opts.on '-e', '--environment ENV', "Application environment (Default: #{config.environment})" do |env|
            config.environment = env
          end

          opts.on '-p', '--port PORT', "UDP check port (Default: #{config.check_port})" do |port|
            config.check_port = Integer(port)
          end

          opts.on '-v', '--verbose', 'Print more verbose output' do |verbose|
            config.verbose = verbose.nil? ? true : verbose
          end
        end
        parser.parse!(args)
        parser
      end


      def initialize_logger
        Crono.logger.level = ::Logger::DEBUG if config.verbose
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


      def launch(self_read)
        @launcher = Crono::Launcher.new(check_port: config.check_port)

        begin
          launcher.run

          while (readable_io = IO.select([self_read]))
            signal = readable_io.first[0].gets.strip
            handle_signal(signal)
          end
        rescue Interrupt
          logger.info "Shutting down"
          fire_event(:shutdown, reverse: true)
          launcher.stop
          logger.info "Bye!"

          exit(0)
        end
      end


      SIGNAL_HANDLERS = {
        # Ctrl-C in terminal
        "INT" => ->(cli) { raise Interrupt },
        # TERM is the signal that Crono must exit.
        # Heroku sends TERM and then waits 30 seconds for process to exit.
        "TERM" => ->(cli) { raise Interrupt },
      }

      def handle_signal(sig)
        logger.debug "Got #{sig} signal"
        SIGNAL_HANDLERS[sig].call(self)
      end

  end
end
