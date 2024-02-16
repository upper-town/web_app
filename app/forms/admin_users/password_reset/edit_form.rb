# frozen_string_literal: true

module AdminUsers
  module PasswordReset
    class EditForm < ApplicationForm
      attribute :password, :string
      attribute :token,    :string

      validates(
        :password,
        :token,
        presence: true
      )

      def method
        :put
      end

      def url
        admin_users_password_reset_path
      end
    end
  end
end
