# frozen_string_literal: true

module Crono
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
