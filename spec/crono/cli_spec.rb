# frozen_string_literal: true

require 'spec_helper'
require 'crono/cli'

RSpec.describe Crono::CLI do
  let(:cli) { described_class.instance }

  describe '#run' do
    it 'initializes rails with #load_rails and start working loop' do
      expect(cli).to receive(:parse_options)
      expect(cli).to receive(:initialize_logger)
      expect(cli).to receive(:load_rails)
      expect(cli).to receive(:have_jobs?).and_return(true)
      expect(cli).to receive(:launch)
      expect(Crono::Cronotab).to receive(:process)
      cli.parse([])
      cli.run
    end
  end

  describe '#parse_options' do
    it 'sets cronotab' do
      cli.send(:parse_options, ['--cronotab', '/tmp/cronotab.rb'])
      expect(cli.config.cronotab).to eql '/tmp/cronotab.rb'
    end

    it 'sets environment' do
      cli.send(:parse_options, ['--environment', 'production'])
      expect(cli.config.environment).to eql('production')
    end
  end
end
