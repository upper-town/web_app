# frozen_string_literal: true

module Users
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
        users_password_reset_path
      end
    end
  end
end
