# frozen_string_literal: true

module Users
  module ChangeEmailConfirmations
    class Create
      attr_reader :change_email_confirmation, :current_user_email, :request, :rate_limiter

      def initialize(change_email_confirmation, current_user_email, request)
        @change_email_confirmation = change_email_confirmation
        @current_user_email = current_user_email
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_change_email_confirmations_create:#{@request.remote_ip}",
          3,
          2.minutes,
          'Too many attempts.'
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

        authenticate_and_change_user_email
      end

      private

      def authenticate_and_change_user_email
        if current_user_email != change_email_confirmation.email
          return Result.failure('Incorrect current email address')
        end

        user = User.authenticate_by(email: current_user_email, password: change_email_confirmation.password)

        if user
          user.update!(change_email: change_email_confirmation.change_email)
          user.unconfirm_change_email!

          schedule_change_email_confirmation_job(user)

          Result.success(user: user)
        else
          Result.failure('Incorrect password')
        end
      end

      def schedule_change_email_confirmation_job(user)
        Users::ChangeEmailConfirmations::EmailJob.perform_in(30.seconds, user.id)
      end
    end
  end
end
