# frozen_string_literal: true

# Configure RSpec
RSpec.configure do |config|
  # Use DB agnostic schema by default
  load Rails.root.join('db', 'schema.rb').to_s

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!

  config.mock_with :rspec do |mocks|
    mocks.allow_message_expectations_on_nil = false
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.start
    Crono.scheduler = Crono::Scheduler.new
  end

  config.after do
    DatabaseCleaner.clean
  end
end
