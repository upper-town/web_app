# frozen_string_literal: true

class PhoneNumberNormalizer
  def initialize(phone_number)
    @phone_number = phone_number.to_s
  end

  def call
    if @phone_number.blank?
      ''
    else
      Phonelib.parse(@phone_number).full_e164
    end
  end
end
