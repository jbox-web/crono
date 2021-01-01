# frozen_string_literal: true

module Crono
  # Crono::PerformerProxy is a proxy used in cronotab.rb semantic
  class PerformerProxy
    def initialize(performer, scheduler, job_args)
      @performer = performer
      @scheduler = scheduler
      @job_args = job_args
    end

    def every(period, **args)
      @job = Job.new(@performer, Period.new(period, **args), @job_args, @options)
      @scheduler.add_job(@job)
      self
    end

    def once_per(execution_interval)
      @job.execution_interval = execution_interval if @job
      self
    end

    def with_options(options)
      @options = options
      self
    end
  end
end
