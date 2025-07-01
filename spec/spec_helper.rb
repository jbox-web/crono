# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

# Start SimpleCov
SimpleCov.start do
  formatter SimpleCov::Formatter::JSONFormatter
  add_filter 'spec/'
end

# Load Rails dummy app
ENV['RAILS_ENV'] = 'test'
require File.expand_path('dummy/config/environment.rb', __dir__)

# Load test gems
require 'rspec/rails'

# Load our own config
require_relative 'config_rspec'

# setting default time zone
# In Rails project, Time.zone_default equals "UTC"
Time.zone_default = Time.find_zone('UTC')
# ActiveRecord::Base.logger = Logger.new(STDOUT)

class TestJob
  def perform; end
end

class TestFailingJob
  def perform
    raise 'Some error'
  end
end
