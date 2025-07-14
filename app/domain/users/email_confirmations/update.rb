# frozen_string_literal: true

module Users
  module EmailConfirmations
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :token, :code

      def initialize(token, code)
        @token = token
        @code = code
      end

      def call
        user = find_user

        if !user
          Result.failure(:invalid_or_expired_token_or_code)
        elsif user.confirmed_email?
          Result.failure(:email_address_already_confirmed, user:)
        else
          ActiveRecord::Base.transaction do
            user.confirm_email!
            user.expire_token!(:email_confirmation)
            user.expire_code!(:email_confirmation)
          end

          Result.success(user:)
        end
      end

      private

      def find_user
        user_by_token = User.find_by_token(:email_confirmation, token)
        user_by_code  = User.find_by_code(:email_confirmation, code)

        user_by_token == user_by_code ? user_by_code : nil
      end
    end
  end
end
