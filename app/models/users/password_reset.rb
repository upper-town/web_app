# frozen_string_literal: true

module Users
  class PasswordReset < ApplicationForm
    attribute :email, :string

    validates :email, presence: true

    def email=(value)
      super(EmailNormalizer.new(value).call)
    end
  end
end
