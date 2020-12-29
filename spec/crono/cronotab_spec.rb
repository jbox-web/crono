require 'spec_helper'

RSpec.describe Crono::Cronotab do
  describe '#process' do
    it 'should load cronotab file' do
      cronotab_path = File.expand_path('../assets/good_cronotab.rb', __FILE__)
      expect(Crono.scheduler).to receive(:add_job).with(kind_of(Crono::Job))
      expect {
        Crono::Cronotab.process(cronotab_path)
      }.to_not raise_error
    end

    it 'should raise error when cronotab is invalid' do
      cronotab_path = File.expand_path('../assets/bad_cronotab.rb', __FILE__)
      expect {
        Crono::Cronotab.process(cronotab_path)
      }.to raise_error(RuntimeError).with_message("period should be at least 1 week to use 'on'")
    end
  end
end
