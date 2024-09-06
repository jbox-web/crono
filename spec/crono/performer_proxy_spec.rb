# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Crono::PerformerProxy do
  it 'adds job to schedule' do
    expect(Crono.scheduler).to receive(:add_job).with(kind_of(Crono::Job))
    Crono.perform(TestJob).every(2.days, at: '15:30')
  end

  it 'sets execution interval' do
    allow(Crono).to receive(:scheduler).and_return(Crono::Scheduler.new)
    expect_any_instance_of(Crono::Job).to receive(:execution_interval=).with(0.minutes).once
    expect_any_instance_of(Crono::Job).to receive(:execution_interval=).with(10.minutes).once
    Crono.perform(TestJob).every(2.days, at: '15:30').once_per 10.minutes
  end

  it 'do nothing when job not initalized' do
    expect_any_instance_of(Crono::Job).to_not receive(:execution_interval=)
    expect_any_instance_of(described_class).to receive(:once_per)
    Crono.perform(TestJob).once_per 10.minutes
  end

  it 'adds job with args to schedule' do
    expect(Crono::Job).to receive(:new).with(TestJob, kind_of(Crono::Period), [:some, { some: 'data' }], nil)
    allow(Crono.scheduler).to receive(:add_job)
    Crono.perform(TestJob, :some, { some: 'data' }).every(2.days, at: '15:30')
  end

  it 'adds job with options to schedule' do
    expect(Crono::Job).to receive(:new).with(TestJob, kind_of(Crono::Period), [], { some_option: true })
    allow(Crono.scheduler).to receive(:add_job)
    Crono.perform(TestJob).with_options(some_option: true).every(2.days, at: '15:30')
  end
end
