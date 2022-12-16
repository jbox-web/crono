# frozen_string_literal: true

RAILS_VERSIONS = %w[
  6.0.6
  6.1.7
  7.0.4
].freeze

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
    gem 'sprockets-rails' if ['7.0.4'].include?(version)
  end
end
