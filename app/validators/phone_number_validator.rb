# frozen_string_literal: true

class PhoneNumberValidator
  attr_reader :phone_number, :errors

  def initialize(phone_number)
    @phone_number = phone_number.to_s
    @errors = [:not_validated_yet]
  end

  def valid?
    errors.clear

    validate_possible

    errors.empty?
  end

  def invalid?
    !valid?
  end

  def validate_possible
    unless Phonelib.parse(phone_number).possible?
      errors << :not_valid
    end
  end
end
