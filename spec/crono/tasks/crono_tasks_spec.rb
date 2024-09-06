# frozen_string_literal: true

require 'spec_helper'
require 'rake'

load 'tasks/crono_tasks.rake'
Rake::Task.define_task(:environment)

RSpec.describe 'Rake' do
  describe 'crono:clean' do
    it 'cleans unused tasks from DB' do
      Crono::CronoJob.create!(job_id: 'used_job')
      ENV['CRONOTAB'] = File.expand_path('../assets/good_cronotab.rb', __dir__)
      Rake::Task['crono:clean'].invoke
      expect(Crono::CronoJob.where(job_id: 'used_job')).to_not exist
    end
  end

  describe 'crono:check' do
    it 'checks cronotab syntax' do
      ENV['CRONOTAB'] = File.expand_path('../assets/bad_cronotab.rb', __dir__)
      expect {
        Rake::Task['crono:check'].invoke
      }.to raise_error(RuntimeError).with_message("period should be at least 1 week to use 'on'")
    end
  end
end
