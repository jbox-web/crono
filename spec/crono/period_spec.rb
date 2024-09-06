# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Crono::Period do
  describe '#description' do
    it 'returns period description' do
      period = described_class.new(1.week, on: :monday, at: '15:20')
      expected_description =
        if ActiveSupport::VERSION::MAJOR >= 5
          'every 1 week at 15:20 on Monday'
        else
          'every 7 days at 15:20 on Monday'
        end
      expect(period.description).to eql(expected_description)
    end
  end

  describe '#next' do
    context 'when in weakly basis' do
      it "raises error if 'on' is wrong" do
        expect { described_class.new(7.days, on: :bad_day) }
          .to raise_error(RuntimeError).with_message("Wrong 'on' day")
      end

      it 'raises error when period is less than 1 week' do
        expect { described_class.new(6.days, on: :monday) }
          .to raise_error(RuntimeError).with_message("period should be at least 1 week to use 'on'")
      end

      it "returns a 'on' day" do
        period = described_class.new(1.week, on: :thursday, at: '15:30')
        current_week = Time.zone.now.beginning_of_week
        last_run_time = current_week.advance(days: 1) # last run on the tuesday
        next_run_at = Time.zone.now.next_week.advance(days: 3).change(hour: 15, min: 30)
        expect(period.next(since: last_run_time)).to eql(next_run_at)
      end

      it "returns a next week day 'on'" do
        period = described_class.new(1.week, on: :thursday)
        Timecop.freeze(Time.zone.now.beginning_of_week.advance(days: 4)) do
          expect(period.next).to eql(Time.zone.now.next_week.advance(days: 3))
        end
      end

      it 'returns a current week day on the first run if not too late' do
        period = described_class.new(7.days, on: :tuesday)
        beginning_of_the_week = Time.zone.now.beginning_of_week
        tuesday = beginning_of_the_week.advance(days: 1)
        Timecop.freeze(beginning_of_the_week) do
          expect(period.next).to eql(tuesday)
        end
      end

      it 'returns today on the first run if not too late' do
        period = described_class.new(1.week, on: :sunday, at: '22:00')
        Timecop.freeze(Time.zone.now.beginning_of_week.advance(days: 6)
                           .change(hour: 21, min: 0)) do
          expect(period.next).to eql(
            Time.zone.now.beginning_of_week.advance(days: 6).change(hour: 22, min: 0)
          )
        end
      end
    end

    context 'when in daily basis' do
      it 'returns Time.zone.now if the next time in past' do
        period = described_class.new(1.day, at: '06:00')
        expect(period.next(since: 2.days.ago).to_s).to eql(Time.zone.now.to_s)
      end

      it 'returns time 2 days from now' do
        period = described_class.new(2.day)
        expect(period.next.to_s).to eql(2.days.from_now.to_s)
      end

      it "sets time to 'at' time as a string" do
        time = 10.minutes.ago
        at = [time.hour, time.min].join(':')
        period = described_class.new(2.days, at: at)
        expect(period.next.to_s).to eql(2.days.from_now.change(hour: time.hour, min: time.min).to_s)
      end

      it "sets time to 'at' time as a hash" do
        time = 10.minutes.ago
        at = { hour: time.hour, min: time.min }
        period = described_class.new(2.days, at: at)
        expect(period.next.to_s).to eql(2.days.from_now.change(at).to_s)
      end

      it "raises error when 'at' is wrong" do
        expect {
          described_class.new(2.days, at: 1)
        }.to raise_error(RuntimeError).with_message("Unknown 'at' format")
      end

      it 'raises error when period is less than 1 day' do
        expect {
          described_class.new(5.hours, at: '15:30')
        }.to raise_error(RuntimeError).with_message("period should be at least 1 day to use 'at' with specified hour")
      end

      it 'returns time in relation to last time' do
        period = described_class.new(2.days)
        expect(period.next(since: 1.day.ago).to_s).to eql(1.day.from_now.to_s)
      end

      it 'returns today time if it is first run and not too late' do
        skip 'wtf?'
        time = 10.minutes.from_now
        at = { hour: time.hour, min: time.min }
        period = described_class.new(2.days, at: at)
        expect(period.next.utc.to_s).to eql(Time.zone.now.change(at).utc.to_s)
      end
    end

    context 'when in hourly basis' do
      it 'returns next hour minutes if current hour minutes passed' do
        Timecop.freeze(Time.zone.now.beginning_of_hour.advance(minutes: 20)) do
          period = described_class.new(1.hour, at: { min: 15 })
          expect(period.next.utc.to_s).to eql 1.hour.from_now.beginning_of_hour.advance(minutes: 15).utc.to_s
        end
      end

      it 'returns current hour minutes if current hour minutes not passed yet' do
        Timecop.freeze(Time.zone.now.beginning_of_hour.advance(minutes: 10)) do
          period = described_class.new(1.hour, at: { min: 15 })
          expect(period.next.utc.to_s).to eql Time.zone.now.beginning_of_hour.advance(minutes: 15).utc.to_s
        end
      end

      it 'returns next hour minutes within the given interval' do
        Timecop.freeze(Time.zone.now.change(hour: 16, min: 10)) do
          period = described_class.new(1.hour, at: { min: 15 }, within: '08:00-16:00')
          expect(period.next.utc.to_s).to eql Time.zone.now.tomorrow.change(hour: 8, min: 15).utc.to_s
        end
        Timecop.freeze(Time.zone.now.change(hour: 16, min: 10)) do
          period = described_class.new(1.hour, at: { min: 15 }, within: '23:00-07:00')
          expect(period.next.utc.to_s).to eql Time.zone.now.change(hour: 23, min: 15).utc.to_s
        end
      end
    end
  end
end
