# frozen_string_literal: true

module Users
  module PasswordResets
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :token, :code, :password

      def initialize(token, code, password)
        @token = token
        @code = code
        @password = password
      end

      def call
        user = find_user

        if !user
          Result.failure(:invalid_or_expired_token_or_code)
        else
          ActiveRecord::Base.transaction do
            user.reset_password!(password)
            user.expire_token!(:password_reset)
            user.expire_code!(:password_reset)
          end

          Result.success(user:)
        end
      end

      private

      def find_user
        user_by_token = User.find_by_token(:password_reset, token)
        user_by_code  = User.find_by_code(:password_reset, code)

        user_by_token == user_by_code ? user_by_code : nil
      end
    end
  end
end
