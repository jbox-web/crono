# frozen_string_literal: true

# require external dependencies
require 'stringio'
require 'logger'

module Crono
  # Crono::Job represents a Crono job
  class Job # rubocop:disable Metrics/ClassLength
    include Util

    attr_accessor :performer, :period, :job_args, :last_performed_at, :job_options,
                  :next_performed_at, :job_log, :job_logger, :healthy, :execution_interval

    def initialize(performer, period, job_args, job_options = nil) # rubocop:disable Metrics/AbcSize
      self.execution_interval = 0.minutes
      self.performer = performer
      self.period = period
      self.job_args = JSON.generate(job_args)
      self.job_log = StringIO.new
      self.job_logger = Logger.new(job_log)
      self.job_options = job_options || {}
      self.next_performed_at = period.next
      @semaphore = Mutex.new
    end

    def next
      return next_performed_at if next_performed_at.future?

      Time.zone.now
    end

    def description
      "Perform #{performer} #{period.description}"
    end

    def job_id
      description
    end

    def perform
      return Thread.new {} if perform_before_interval? # rubocop:disable Lint/EmptyBlock

      log "Perform #{performer}"
      self.last_performed_at = Time.zone.now
      self.next_performed_at = period.next(since: last_performed_at)

      Thread.new { perform_job }
    end

    def save
      @semaphore.synchronize do
        update_model
        clear_job_log
        ActiveRecord::Base.connection_handler.clear_active_connections!
      end
    end

    def load
      self.last_performed_at = model.last_performed_at
      self.next_performed_at = period.next(since: last_performed_at)
    end

    private

      def clear_job_log
        job_log.truncate(job_log.rewind)
      end

      def truncate_log(log)
        return log.lines.last(job_options[:truncate_log]).join if job_options[:truncate_log]

        log
      end

      def update_model
        saved_log = model.reload.log || ''
        log_to_save = saved_log + job_log.string
        log_to_save = truncate_log(log_to_save)
        model.update(last_performed_at: last_performed_at, log: log_to_save, healthy: healthy)
      end

      def perform_job
        performer.new.perform(*JSON.parse(job_args))
      rescue StandardError => e
        handle_job_fail(e)
      else
        handle_job_success
      ensure
        save
      end

      def handle_job_fail(exception)
        finished_time_sec = format('%.2f', Time.zone.now - last_performed_at)
        self.healthy = false
        log_error "Finished #{performer} in #{finished_time_sec} seconds with error: #{exception.message}"
        log_error exception.backtrace.join("\n")
      end

      def handle_job_success
        finished_time_sec = format('%.2f', Time.zone.now - last_performed_at)
        self.healthy = true
        log "Finished #{performer} in #{finished_time_sec} seconds"
      end

      def log_error(message)
        log(message, Logger::ERROR)
      end

      def log(message, severity = Logger::INFO)
        @semaphore.synchronize do
          logger&.add(severity, message)
          job_logger.add(severity, message)
        end
      end

      def model
        @model ||= Crono::CronoJob.find_or_create_by(job_id: job_id)
      end

      def perform_before_interval? # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
        return false if execution_interval == 0.minutes

        return true if last_performed_at.present? && last_performed_at > execution_interval.ago

        if model.updated_at.present? && model.created_at != model.updated_at && model.updated_at > execution_interval.ago
          return true
        end

        Crono::CronoJob.transaction do
          job_record = Crono::CronoJob.where(job_id: job_id).lock(true).first

          return true if  job_record.updated_at.present? &&
                          job_record.updated_at != job_record.created_at &&
                          job_record.updated_at > execution_interval.ago

          job_record.touch

          return true unless job_record.save
        end

        # Means that this node is permit to perform the job.
        false
      end

  end
end
