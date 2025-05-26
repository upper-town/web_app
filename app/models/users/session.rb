# frozen_string_literal: true

module Users
  class Session < ApplicationModel
    attribute :email,       :string,  default: nil
    attribute :password,    :string,  default: nil
    attribute :remember_me, :boolean, default: false

    validates :email,
      presence: true,
      length: { minimum: 3, maximum: 255 },
      email: true

    validates :password,
      presence: true,
      length: { maximum: 255 }

    def email=(value)
      super(NormalizeEmail.call(value))
    end
  end
end
