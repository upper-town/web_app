# frozen_string_literal: true

module Users
  class ChangeEmailReversion < ApplicationModel
    attribute :token, :string, default: nil
    attribute :code,  :string, default: nil

    validates :token, presence: true, length: { maximum: 255 }
    validates :code,  presence: true, length: { maximum: 255 }

    def token=(value)
      super(NormalizeToken.call(value))
    end

    def code=(value)
      super(NormalizeCode.call(value))
    end
  end
end
