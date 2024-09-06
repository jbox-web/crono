# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Crono::CronoJob do # rubocop:disable RSpec/SpecFilePathFormat
  let(:valid_attrs) do
    {
      job_id: 'Perform TestJob every 3 days',
    }
  end

  it 'validates presence of job_id' do
    crono_job = described_class.new
    expect(crono_job).to_not be_valid
    expect(crono_job.errors.added?(:job_id, :blank)).to be true
  end

  it 'validates uniqueness of job_id' do
    described_class.create!(job_id: 'TestJob every 2 days')
    crono_job = described_class.create(job_id: 'TestJob every 2 days')
    expect(crono_job).to_not be_valid
    expect(crono_job.errors[:job_id]).to eq ['has already been taken']
  end

  it 'saves job_id to DB' do
    described_class.create!(valid_attrs)
    crono_job = described_class.find_by(job_id: valid_attrs[:job_id])
    expect(crono_job).to be_present
  end
end
