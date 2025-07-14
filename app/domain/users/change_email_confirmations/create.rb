# frozen_string_literal: true

module Users
  module ChangeEmailConfirmations
    class Create
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :email, :change_email, :password, :current_user_email

      def initialize(email, change_email, password, current_user_email)
        @email = email
        @change_email = change_email
        @password = password
        @current_user_email = current_user_email
      end

      def call
        if ActiveSupport::SecurityUtils.secure_compare(email, current_user_email)
          authenticate_and_change_user_email
        else
          Result.failure(:incorrect_current_email)
        end
      end

      private

      def authenticate_and_change_user_email
        user = User.authenticate_by(email: current_user_email, password:)

        if !user
          Result.failure(:incorrect_password_or_email)
        else
          ActiveRecord::Base.transaction do
            user.update!(change_email:)
            user.unconfirm_change_email!
          end

          EmailJob.perform_later(user)
          Result.success(user:)
        end
      end
    end
  end
end
