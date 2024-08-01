# frozen_string_literal: true

require_relative 'lib/crono/version'

Gem::Specification.new do |s|
  s.name        = 'crono'
  s.version     = Crono::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Dzmitry Plashchynski']
  s.email       = ['plashchynski@gmail.com']
  s.homepage    = 'https://github.com/plashchynski/crono'
  s.summary     = 'Job scheduler for Rails'
  s.description = 'A time-based background job scheduler daemon (just like Cron) for Rails'
  s.license     = 'Apache-2.0'

  s.required_ruby_version = '>= 3.0.0'

  s.files = `git ls-files`.split("\n")

  s.bindir      = 'exe'
  s.executables = ['crono']

  s.add_runtime_dependency 'rails', '>= 6.1'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rake'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'sqlite3', '~> 1.5.0'
  s.add_development_dependency 'timecop'

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.1.0')
    s.add_development_dependency 'net-imap'
    s.add_development_dependency 'net-pop'
    s.add_development_dependency 'net-smtp'
  end

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4.0')
    s.add_development_dependency 'base64'
    s.add_development_dependency 'bigdecimal'
    s.add_development_dependency 'mutex_m'
    s.add_development_dependency 'drb'
  end
end
