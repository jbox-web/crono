require 'spec_helper'

RSpec.describe Crono::Config do
  let(:config) { Crono::Config.new }
  describe '#initialize' do
    it 'should initialize with default configuration options' do
      ENV['RAILS_ENV'] = 'test'
      @config = Crono::Config.new
      expect(@config.cronotab).to be Crono::Config::CRONOTAB
      expect(@config.environment).to be_eql ENV['RAILS_ENV']
    end
  end
end
