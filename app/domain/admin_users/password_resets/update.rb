# frozen_string_literal: true

module AdminUsers
  module PasswordResets
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :admin_user
      end

      attr_reader :token, :code, :password

      def initialize(token, code, password)
        @token = token
        @code = code
        @password = password
      end

      def call
        admin_user = find_admin_user

        if !admin_user
          Result.failure(:invalid_or_expired_token_or_code)
        else
          ActiveRecord::Base.transaction do
            admin_user.reset_password!(password)
            admin_user.expire_token!(:password_reset)
            admin_user.expire_code!(:password_reset)
          end

          Result.success(admin_user:)
        end
      end

      private

      def find_admin_user
        admin_user_by_token = AdminUser.find_by_token(:password_reset, token)
        admin_user_by_code  = AdminUser.find_by_code(:password_reset, code)

        admin_user_by_token == admin_user_by_code ? admin_user_by_code : nil
      end
    end
  end
end
