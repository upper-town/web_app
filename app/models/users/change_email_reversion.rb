# frozen_string_literal: true

module Users
  class ChangeEmailReversion < ApplicationModel
    attribute :token, :string, default: nil
    attribute :auto_click, :boolean, default: false

    validates :token, presence: true, length: { maximum: 255 }

    def token=(value)
      super(NormalizeToken.call(value))
    end
  end
end
