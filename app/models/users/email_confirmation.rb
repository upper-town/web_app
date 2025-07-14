# frozen_string_literal: true

module Users
  class EmailConfirmation < ApplicationModel
    attr_accessor :action

    attribute :email, :string, default: nil

    attribute :token, :string, default: nil
    attribute :code,  :string, default: nil

    with_options if: -> { action == :create } do
      validates :email, presence: true, length: { minimum: 3, maximum: 255 }, email: true
    end

    with_options if: -> { action == :update } do
      validates :token, presence: true, length: { maximum: 255 }
      validates :code,  presence: true, length: { maximum: 255 }
    end

    def email=(value)
      super(NormalizeEmail.call(value))
    end

    def token=(value)
      super(NormalizeToken.call(value))
    end

    def code=(value)
      super(NormalizeCode.call(value))
    end
  end
end
