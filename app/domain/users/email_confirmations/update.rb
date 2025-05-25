# frozen_string_literal: true

module Users
  module EmailConfirmations
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :email_confirmation_edit, :request, :rate_limiter

      def initialize(email_confirmation_edit, request)
        @email_confirmation_edit = email_confirmation_edit
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_email_confirmation_update:#{request.remote_ip}",
          2,
          5.minutes,
          "Too many attempts"
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

        user = find_user

        if !user
          Result.failure("Invalid or expired token")
        elsif user.confirmed_email?
          Result.failure("Email address has already been confirmed", user: user)
        else
          confirm_email(user)
        end
      end

      private

      def find_user
        User.find_by_token(:email_confirmation, email_confirmation_edit.token)
      end

      def confirm_email(user)
        begin
          ActiveRecord::Base.transaction do
            user.confirm_email!
            user.expire_token!(:email_confirmation)
          end
        rescue StandardError => e
          rate_limiter.uncall

          raise e
        end

        Result.success(user: user)
      end
    end
  end
end
