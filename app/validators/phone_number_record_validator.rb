# frozen_string_literal: true

class PhoneNumberRecordValidator
  DEFAULT_ATTRIBUTE_NAME = :phone_number

  attr_reader :record, :attribute_name, :attribute_value, :validator

  def initialize(record, options = {})
    @record = record

    @attribute_name  = options[:attribute_name] || DEFAULT_ATTRIBUTE_NAME
    @attribute_value = record.public_send(attribute_name)

    @validator = PhoneNumberValidator.new(attribute_value)
  end

  def validate
    return if attribute_value.blank?

    validator.valid?

    validator.errors.each do |message|
      record.errors.add(attribute_name, message)
    end
  end
end
