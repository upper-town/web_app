# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.inheritance_column = 'record_type'

  primary_abstract_class
end
