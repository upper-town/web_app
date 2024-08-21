# frozen_string_literal: true

module Users
  class ChangeEmailConfirmation < ApplicationModel
    attribute :email, :string
    attribute :change_email, :string
    attribute :password, :string

    validates :email, presence: true
    validates :change_email, presence: true, email: true
    validates :password, presence: true

    def email=(value)
      super(EmailNormalizer.new(value).call)
    end

    def change_email=(value)
      super(EmailNormalizer.new(value).call)
    end
  end
end
