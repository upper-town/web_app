# frozen_string_literal: true

module AdminUsers
  class Session < ApplicationForm
    attribute :email, :string
    attribute :password, :string
    attribute :remember_me, :boolean

    validates(
      :email,
      :password,
      presence: true
    )

    def email=(value)
      super(EmailNormalizer.new(value).call)
    end
  end
end
