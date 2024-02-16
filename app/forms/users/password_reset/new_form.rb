# frozen_string_literal: true

module Users
  module PasswordReset
    class NewForm < ApplicationForm
      attribute :email, :string

      validates :email, presence: true

      def email=(value)
        super(EmailNormalizer.new(value).call)
      end

      def method
        :post
      end

      def url
        users_password_reset_path
      end
    end
  end
end
