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

  s.required_ruby_version = '>= 3.1.0'

  s.files = Dir[
    'README.md',
    'CHANGELOG.md',
    'LICENSE',
    'lib/**/*.rb',
    'lib/**/*.erb',
    'lib/**/*.rake',
    'exe/*.rb',
    'app/**/*.rb',
    'app/**/*.erb'
  ]

  s.bindir      = 'exe'
  s.executables = ['crono']

  s.add_dependency 'rails', '>= 7.0'
end
