# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.inheritance_column = "record_type"

  primary_abstract_class

  def move_errors(attr_from, attr_to)
    errors.where(attr_from).each { errors.add(attr_to, it.type, **it.options) }
    errors.delete(attr_from)
  end
end
