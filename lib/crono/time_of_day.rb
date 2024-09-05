# frozen_string_literal: true

module Crono
  # TimeOfDay describes a certain hour and minute (on any day)
  class TimeOfDay
    include Comparable

    attr_accessor :hour, :min

    def self.parse(value)
      time =
        case value
        when String then Time.zone.parse(value).utc
        when Hash   then Time.zone.now.change(value).utc
        when Time   then value.utc
        else
          raise "Unknown TimeOfDay format: #{value.inspect}"
        end
      new time.hour, time.min
    end

    def initialize(hour, min)
      @hour = hour
      @min  = min
    end

    def to_i
      (@hour * 60) + @min
    end

    def to_s
      format('%02d:%02d', @hour, @min) # rubocop:disable Style/FormatStringToken
    end

    def <=>(other)
      to_i <=> other.to_i
    end
  end
end
