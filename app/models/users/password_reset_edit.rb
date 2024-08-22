# frozen_string_literal: true

module Users
  class PasswordResetEdit < ApplicationModel
    attribute :token, :string, default: nil
    attribute :password, :string, default: nil

    validates :token, presence: true, length: { maximum: 255 }
    validates :password, presence: true, length: { maximum: 255 }

    def token=(value)
      super(NormalizeToken.call(value))
    end
  end
end
