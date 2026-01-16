# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Crono::Cronotab do
  describe '#process' do
    context 'when cronotab is valid' do
      let(:cronotab_path) { File.expand_path('assets/good_cronotab.rb', __dir__) }

      it 'loads cronotab file' do
        allow(Crono.scheduler).to receive(:add_job).with(kind_of(Crono::Job))

        expect {
          described_class.process(cronotab_path)
        }.to_not raise_error

        expect(Crono.scheduler).to have_received(:add_job).with(kind_of(Crono::Job))
      end
    end

    context 'when cronotab is invalid' do
      let(:cronotab_path) { File.expand_path('assets/bad_cronotab.rb', __dir__) }

      it 'raises error' do
        expect {
          described_class.process(cronotab_path)
        }.to raise_error(RuntimeError).with_message("period should be at least 1 week to use 'on'")
      end
    end
  end
end
