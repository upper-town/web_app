# frozen_string_literal: true

module Users
  module ChangeEmailReversions
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :change_email_reversion_edit

      def initialize(change_email_reversion_edit)
        @change_email_reversion_edit = change_email_reversion_edit
      end

      def call
        user, token = find_user_and_token

        if !user || !token
          Result.failure("Invalid or expired token")
        elsif token.data["email"].blank?
          Result.failure("Invalid token: old email address is not associated with token")
        else
          revert_change_email(user, token)
        end
      end

      private

      def find_user_and_token
        [
          User.find_by_token(:change_email_reversion, change_email_reversion_edit.token),
          Token.find_by_token(change_email_reversion_edit.token)
        ]
      end

      def revert_change_email(user, token)
        ActiveRecord::Base.transaction do
          user.revert_change_email!(token.data["email"])
          token.expire!
        end

        Result.success(user: user)
      end
    end
  end
end
