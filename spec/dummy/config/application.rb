# frozen_string_literal: true

# Load Bundler
require_relative 'boot'

# Load Rails
require 'rails/all'

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
  end
end
