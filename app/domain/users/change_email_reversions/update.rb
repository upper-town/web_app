# frozen_string_literal: true

module Users
  module ChangeEmailReversions
    class Update
      attr_reader :change_email_reversion_edit, :request, :rate_limiter

      def initialize(change_email_reversion_edit, request)
        @change_email_reversion_edit = change_email_reversion_edit
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_change_email_reversions_update:#{request.remote_ip}",
          3,
          2.minutes,
          "Too many attempts"
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

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
        begin
          ActiveRecord::Base.transaction do
            user.revert_change_email!(token.data["email"])
            token.expire!
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
