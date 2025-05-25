# frozen_string_literal: true

module Users
  module PasswordResets
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :password_reset_edit

      def initialize(password_reset_edit)
        @password_reset_edit = password_reset_edit
      end

      def call
        user = find_user

        if user
          reset_password(user)
        else
          Result.failure("Invalid or expired token")
        end
      end

      private

      def find_user
        User.find_by_token(:password_reset, password_reset_edit.token)
      end

      def reset_password(user)
        ActiveRecord::Base.transaction do
          user.reset_password!(password_reset_edit.password)
          user.expire_token!(:password_reset)
        end

        Result.success(user: user)
      end
    end
  end
end
