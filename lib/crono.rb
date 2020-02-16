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
end
