# frozen_string_literal: true

# require internal dependencies
require_relative 'time_of_day'

module Crono
  # Interval describes a period between two specific times of day
  class Interval
    attr_accessor :from, :to

    def self.parse(value)
      from_to =
        case value
        when Array  then value
        when Hash   then value.values_at(:from, :to)
        when String then value.split('-')
        else
          raise "Unknown interval format: #{value.inspect}"
        end
      from, to = from_to.map { |v| TimeOfDay.parse(v) }
      new from, to
    end

    def initialize(from, to)
      @from = from
      @to = to
    end

    def within?(value)
      tod = value.is_a?(TimeOfDay) ? value : TimeOfDay.parse(value)
      if @from <= @to
        tod >= @from && tod < @to
      else
        tod >= @from || tod < @to
      end
    end

    def next_within(time, period)
      loop do
        time = period.since(time)
        break if within?(TimeOfDay.parse(time))
      end
      time
    end

    def to_s
      "#{@from}-#{@to}"
    end
  end
end
