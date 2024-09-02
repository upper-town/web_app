# frozen_string_literal: true

module Users
  module ChangeEmailConfirmations
    class Update
      attr_reader :change_email_confirmation_edit, :request, :rate_limiter

      def initialize(change_email_confirmation_edit, request)
        @change_email_confirmation_edit = change_email_confirmation_edit
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_change_email_confirmations_update:#{request.remote_ip}",
          3,
          2.minutes,
          'Too many attempts.'
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

        user, token = find_user_and_token

        if !user || !token
          Result.failure('Invalid or expired token.')
        elsif user.confirmed_change_email?
          Result.failure('New Email address has already been confirmed.', user: user)
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
        if user.invalid?
          return Result.failure(user.errors, user: user)
        end

        if token.data['change_email'].blank? || user.change_email != token.data['change_email']
          return Result.failure('Invalid token: new email address is not associated with token')
        end

        begin
          ActiveRecord::Base.transaction do
            user.update!(
              email: token.data['change_email'],
              change_email: nil
            )
            user.confirm_change_email!
            user.confirm_email!
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
