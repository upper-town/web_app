# frozen_string_literal: true

class NormalizePhoneNumber
  include Callable

  attr_reader :phone_number

  def initialize(phone_number)
    @phone_number = phone_number
  end

  def call
    return if phone_number.nil?
    return "" if phone_number.blank?

    Phonelib.parse(phone_number.gsub(/[[:space:]]/, "")).full_e164
  end
end
