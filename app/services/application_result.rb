# frozen_string_literal: true

class ApplicationResult < ApplicationModel
  DEFAULT_ERROR_KEY  = :base
  DEFAULT_ERROR_TYPE = :invalid

  def self.success(...)
    new(...)
  end

  def self.failure(error_value = DEFAULT_ERROR_KEY, error_type = DEFAULT_ERROR_TYPE, **)
    error_value = DEFAULT_ERROR_KEY if error_value.blank?

    new(**).tap { it.add_error(error_value, error_type) }
  end

  def success?
    errors.empty?
  end

  def failure?
    !success?
  end

  def add_error(value, type = DEFAULT_ERROR_TYPE)
    type = DEFAULT_ERROR_TYPE if type.blank?

    case value
    when Symbol
      errors.add(value, type) if value.present?
    when Numeric
      errors.add(value.to_s, type)
    when String
      errors.add(DEFAULT_ERROR_KEY, value) if value.present?
    when ActiveModel::Errors
      errors.merge!(value)
    when true
      errors.add(DEFAULT_ERROR_KEY, DEFAULT_ERROR_TYPE)
    when nil, false
      # Nothing
    else
      raise "ApplicationResult: invalid class for error: #{value.class.name}"
    end
  end

  # The following methods are needed for ActiveModel::Errors

  def read_attribute_for_validation(attr)
    attr
  end

  def self.human_attribute_name(attr, _options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end
end
