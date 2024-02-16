# frozen_string_literal: true

class EmailNormalizer
  def self.call(...)
    new(...).call
  end

  def initialize(email)
    @email = email
  end

  def call
    return if @email.nil?

    @email.gsub(/[[:space:]]/, '').downcase
  end
end
