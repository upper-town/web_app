# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.inheritance_column = nil

  primary_abstract_class
end
