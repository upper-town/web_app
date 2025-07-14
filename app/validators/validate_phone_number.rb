# frozen_string_literal: true

class ValidatePhoneNumber
  attr_reader :phone_number, :errors

  def initialize(phone_number)
    @phone_number = phone_number.to_s
    @errors = [:not_yet_validated]
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
      @errors << :invalid
    end
  end
end
