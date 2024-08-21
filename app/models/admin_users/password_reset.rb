# frozen_string_literal: true

module AdminUsers
  class PasswordReset < ApplicationModel
    attribute :email, :string

    validates :email, presence: true

    def email=(value)
      super(NormalizeEmail.call(value))
    end
  end
end
