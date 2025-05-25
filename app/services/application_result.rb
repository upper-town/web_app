# frozen_string_literal: true

class ApplicationResult < ApplicationModel
  GENERIC_ERROR = :generic_error

  def self.success(...)
    new(...)
  end

  def self.failure(error_values = GENERIC_ERROR, **)
    # Ensure errors presence when creating a Result by calling .failure
    error_values = error_values.compact_blank if error_values.is_a?(Array) || error_values.is_a?(Hash)
    error_values = GENERIC_ERROR if error_values.blank?

    new(**).tap { it.add_errors(error_values) }
  end

  def success?
    errors.empty?
  end

  def failure?
    !success?
  end

  def add_errors(error_values)
    case error_values
    when Hash
      add_errors_from_hash(error_values)
    when Array
      add_errors_from_array(:base, error_values)
    when Symbol, String, Numeric
      add_errors_from_literal(:base, error_values)
    when ActiveModel::Errors
      add_errors_from_active_model_errors(error_values)
    when true
      add_errors_from_literal(:base, GENERIC_ERROR)
    when nil, false
      # Nothing
    else
      raise "ApplicationResult: invalid error_values.class: #{error_values.class.name}"
    end
  end

  private

  def add_errors_from_hash(hash)
    hash.each do |key, value|
      if value.is_a?(Array)
        add_errors_from_array(key, value)
      else
        add_errors_from_literal(key, value)
      end
    end
  end

  def add_errors_from_array(key, array)
    array.each do |value|
      add_errors_from_literal(key, value)
    end
  end

  def add_errors_from_literal(key, value)
    return if value.blank?

    case value
    when Symbol
      errors.add(key.to_sym, value)
    when String, Numeric
      errors.add(key.to_sym, value.to_s)
    end
  end

  def add_errors_from_active_model_errors(active_model_errors)
    errors.merge!(active_model_errors)
  end
end
