# frozen_string_literal: true

class Result
  extend ActiveModel::Naming # Required dependency for ActiveModel::Errors

  GENERIC_ERROR = 'An error has occurred'

  attr_reader :errors
  attr_reader :data

  alias attributes data

  def self.success(data = {})
    new(nil, data)
  end

  def self.failure(error_values = GENERIC_ERROR, data = {})
    # Ensure errors presence when creating a Result by calling .failure
    error_values = error_values.compact_blank if error_values.is_a?(Array) || error_values.is_a?(Hash)
    error_values = GENERIC_ERROR if error_values.blank?

    new(error_values, data)
  end

  def initialize(error_values = {}, data = {})
    @errors = ActiveModel::Errors.new(self)
    @data = data.with_indifferent_access

    add_errors(error_values)
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
    when String, Symbol, Numeric
      add_errors_from_literal(:base, error_values)
    when ActiveModel::Errors
      add_errors_from_active_model_errors(error_values)
    when true
      add_errors_from_literal(:base, GENERIC_ERROR)
    when nil, false
      # Nothing
    else
      raise "Could not build_active_model_errors for Result: invalid error_values.class: #{error_values.class.name}"
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
    errors.add(key.to_sym, value.to_s) if value.present?
  end

  def add_errors_from_active_model_errors(active_model_errors)
    errors.merge!(active_model_errors)
  end
end
