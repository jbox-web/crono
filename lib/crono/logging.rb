# frozen_string_literal: true

module Crono
  # Crono::Logging is a standart Ruby logger wrapper
  module Logging
    def logfile=(logfile)
      Crono.logger = Logger.new(logfile)
    end

    def logger
      Crono.logger
    end
  end
end
