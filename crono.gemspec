# frozen_string_literal: true

require_relative 'lib/crono/version'

Gem::Specification.new do |s|
  s.name        = 'crono'
  s.version     = Crono::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Dzmitry Plashchynski']
  s.email       = ['plashchynski@gmail.com']
  s.homepage    = 'https://github.com/plashchynski/crono'
  s.summary     = 'Job scheduler for Rails'
  s.description = 'A time-based background job scheduler daemon (just like Cron) for Rails'
  s.license     = 'Apache-2.0'

  s.required_ruby_version = '>= 2.4.4'

  s.files = `git ls-files`.split("\n")

  s.bindir      = 'exe'
  s.executables = ['crono']

  s.add_runtime_dependency 'rails', '>= 5.0'
  s.add_runtime_dependency 'zeitwerk'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'daemons'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'sqlite3', '~> 1.4.0'
end
