# frozen_string_literal: true

class NormalizeEmail
  include Callable

  attr_reader :email

  def initialize(email)
    @email = email
  end

  def call
    return if email.nil?
    return "" if email.blank?

    email.gsub(/[[:space:]]/, "").downcase
  end
end
