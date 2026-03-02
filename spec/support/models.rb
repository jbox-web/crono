# frozen_string_literal: true

class TestJob
  def perform; end
end

class TestFailingJob
  def perform
    raise 'Some error'
  end
end
