# frozen_string_literal: true

module Users
  class ChangeEmailConfirmation < ApplicationForm
    attribute :email, :string
    attribute :change_email, :string
    attribute :password, :string

    validates(
      :email,
      :change_email,
      :password,
      presence: true
    )

    validate do |record|
      EmailRecordValidator.new(record, attribute_name: :change_email).validate
    end

    def email=(value)
      super(EmailNormalizer.new(value).call)
    end

    def change_email=(value)
      super(EmailNormalizer.new(value).call)
    end
  end
end
