# frozen_string_literal: true

class NormalizePhoneNumber
  include Callable

  attr_reader :str

  def initialize(str)
    @str = str
  end

  def call
    return if str.nil?
    return "" if str.blank?

    Phonelib.parse(str.gsub(/[[:space:]]/, "")).full_e164
  end
end
