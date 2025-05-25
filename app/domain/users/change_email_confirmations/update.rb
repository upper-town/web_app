# frozen_string_literal: true

module Users
  module ChangeEmailConfirmations
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :change_email_confirmation_edit

      def initialize(change_email_confirmation_edit)
        @change_email_confirmation_edit = change_email_confirmation_edit
      end

      def call
        user, token = find_user_and_token

        if !user || !token
          Result.failure("Invalid or expired token")
        elsif user.confirmed_change_email?
          Result.failure("New Email address has already been confirmed")
        elsif token.data["change_email"].blank? || token.data["change_email"] != user.change_email
          Result.failure("Invalid token: new email address is not associated with token")
        else
          confirm_change_email(user, token)
        end
      end

      private

      def find_user_and_token
        [
          User.find_by_token(:change_email_confirmation, change_email_confirmation_edit.token),
          Token.find_by_token(change_email_confirmation_edit.token)
        ]
      end

      def confirm_change_email(user, token)
        ActiveRecord::Base.transaction do
          user.update!(
            email: token.data["change_email"],
            change_email: nil
          )
          user.confirm_change_email!
          user.confirm_email!
          token.expire!
        end

        Result.success(user: user)
      end
    end
  end
end
