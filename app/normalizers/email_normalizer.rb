# frozen_string_literal: true

class EmailNormalizer
  def self.call(*args)
    new(*args).call
  end

  def initialize(email)
    @email = email.to_s
  end

  def call
    @email.gsub(/[[:space:]]/, '').downcase
  end
end
