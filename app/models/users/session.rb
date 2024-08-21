# frozen_string_literal: true

module Users
  class Session < ApplicationModel
    attribute :email, :string
    attribute :password, :string
    attribute :remember_me, :boolean

    validates(
      :email,
      :password,
      presence: true
    )

    def email=(value)
      super(NormalizeEmail.call(value))
    end
  end
end
