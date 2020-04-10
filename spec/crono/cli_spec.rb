require 'spec_helper'

RSpec.describe Crono::CLI do
  let(:cli) { Crono::CLI.instance }

  describe '#run' do
    it 'should initialize rails with #load_rails and start working loop' do
      expect(cli).to receive(:load_rails)
      expect(cli).to receive(:have_jobs?).and_return(true)
      expect(cli).to receive(:start_working_loop)
      expect(cli).to receive(:parse_options)
      expect(Crono::Cronotab).to receive(:process)
      cli.run([])
    end
  end

  describe '#parse_options' do
    it 'should set cronotab' do
      cli.send(:parse_options, ['--cronotab', '/tmp/cronotab.rb'])
      expect(cli.config.cronotab).to be_eql '/tmp/cronotab.rb'
    end

    it 'should set environment' do
      cli.send(:parse_options, ['--environment', 'production'])
      expect(cli.config.environment).to be_eql('production')
    end
  end
end
