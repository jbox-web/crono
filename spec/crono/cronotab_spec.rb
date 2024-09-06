# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Crono::Cronotab do
  describe '#process' do
    it 'loads cronotab file' do
      cronotab_path = File.expand_path('assets/good_cronotab.rb', __dir__)
      expect(Crono.scheduler).to receive(:add_job).with(kind_of(Crono::Job))
      expect {
        described_class.process(cronotab_path)
      }.to_not raise_error
    end

    it 'raises error when cronotab is invalid' do
      cronotab_path = File.expand_path('assets/bad_cronotab.rb', __dir__)
      expect {
        described_class.process(cronotab_path)
      }.to raise_error(RuntimeError).with_message("period should be at least 1 week to use 'on'")
    end
  end
end
