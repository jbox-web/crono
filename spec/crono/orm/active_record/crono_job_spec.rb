require 'spec_helper'

RSpec.describe Crono::CronoJob do
  let(:valid_attrs) do
    {
      job_id: 'Perform TestJob every 3 days'
    }
  end

  it 'should validate presence of job_id' do
    @crono_job = Crono::CronoJob.new
    expect(@crono_job).not_to be_valid
    expect(@crono_job.errors.added?(:job_id, :blank)).to be true
  end

  it 'should validate uniqueness of job_id' do
    Crono::CronoJob.create!(job_id: 'TestJob every 2 days')
    @crono_job = Crono::CronoJob.create(job_id: 'TestJob every 2 days')
    expect(@crono_job).not_to be_valid
    expect(@crono_job.errors[:job_id]).to eq ['has already been taken']
  end

  it 'should save job_id to DB' do
    Crono::CronoJob.create!(valid_attrs)
    @crono_job = Crono::CronoJob.find_by(job_id: valid_attrs[:job_id])
    expect(@crono_job).to be_present
  end
end
