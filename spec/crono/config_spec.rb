# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Crono::Config do
  let(:config) { described_class.new }

  describe '#initialize' do
    it 'initializes with default configuration options' do
      ENV['RAILS_ENV'] = 'test'
      expect(config.cronotab).to be Crono::Config::CRONOTAB
      expect(config.environment).to eql ENV.fetch('RAILS_ENV', nil)
    end
  end
end
