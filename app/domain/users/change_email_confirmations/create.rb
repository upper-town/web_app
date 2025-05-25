# frozen_string_literal: true

module Users
  module ChangeEmailConfirmations
    class Create
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :change_email_confirmation, :current_user_email

      def initialize(change_email_confirmation, current_user_email)
        @change_email_confirmation = change_email_confirmation
        @current_user_email = current_user_email
      end

      def call
        if current_user_email != change_email_confirmation.email
          Result.failure("Incorrect current email address")
        else
          authenticate_and_change_user_email
        end
      end

      private

      def authenticate_and_change_user_email
        user = User.authenticate_by(email: current_user_email, password: change_email_confirmation.password)
        return Result.failure("Incorrect password") unless user

        ActiveRecord::Base.transaction do
          user.update!(change_email: change_email_confirmation.change_email)
          user.unconfirm_change_email!
        end

        Users::ChangeEmailConfirmations::EmailJob
          .set(wait: 30.seconds)
          .perform_later(user)

        Result.success(user: user)
      end
    end
  end
end
