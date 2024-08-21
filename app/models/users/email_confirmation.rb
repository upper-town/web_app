# frozen_string_literal: true

module Users
  class EmailConfirmation < ApplicationModel
    attribute :email, :string, default: nil

    validates :email, presence: true, length: { minimum: 3, maximum: 255 }

    def email=(value)
      super(EmailNormalizer.new(value).call)
    end
  end
end
