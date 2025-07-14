# frozen_string_literal: true

module AdminUsers
  module EmailConfirmations
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :admin_user
      end

      attr_reader :token, :code

      def initialize(token, code)
        @token = token
        @code = code
      end

      def call
        admin_user = find_admin_user

        if !admin_user
          Result.failure(:invalid_or_expired_token_or_code)
        elsif admin_user.confirmed_email?
          Result.failure(:email_address_already_confirmed, admin_user:)
        else
          ActiveRecord::Base.transaction do
            admin_user.confirm_email!
            admin_user.expire_token!(:email_confirmation)
            admin_user.expire_code!(:email_confirmation)
          end

          Result.success(admin_user:)
        end
      end

      private

      def find_admin_user
        admin_user_by_token = AdminUser.find_by_token(:email_confirmation, token)
        admin_user_by_code  = AdminUser.find_by_code(:email_confirmation, code)

        admin_user_by_token == admin_user_by_code ? admin_user_by_code : nil
      end
    end
  end
end
