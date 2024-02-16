# frozen_string_literal: true

module AdminUsers
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
        admin_users_password_reset_path
      end
    end
  end
end
