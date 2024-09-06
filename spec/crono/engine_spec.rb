# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Crono::Engine do
  include Rack::Test::Methods

  let(:app) { Rails.application }
  let(:test_job_id) { 'Perform TestJob every 5 seconds' }
  let(:test_job_log) { 'All runs ok' }
  let(:test_job) { Crono::CronoJob.create!(job_id: test_job_id, log: test_job_log) }

  before { Crono::CronoJob.destroy_all }

  describe '/' do
    it 'shows all jobs' do
      test_job
      get '/crono'
      expect(last_response).to be_ok
      expect(last_response.body).to include test_job_id
    end

    it 'shows a error mark when a job is unhealthy' do
      test_job.update(healthy: false, last_performed_at: 10.minutes.ago)
      get '/crono'
      expect(last_response.body).to include 'Error'
    end

    it 'shows a success mark when a job is healthy' do
      test_job.update(healthy: true, last_performed_at: 10.minutes.ago)
      get '/crono'
      expect(last_response.body).to include 'Success'
    end

    it 'shows a pending mark when a job is pending' do
      test_job.update(healthy: nil)
      get '/crono'
      expect(last_response.body).to include 'Pending'
    end
  end

  describe '/job/:id' do
    it 'shows job log' do
      get "/crono/jobs/#{test_job.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to include test_job_id
      expect(last_response.body).to include test_job_log
    end

    it 'shows a message about the unhealthy job' do
      message = 'An error occurs during the last execution of this job'
      test_job.update(healthy: false)
      get "/crono/jobs/#{test_job.id}"
      expect(last_response.body).to include message
    end
  end
end
