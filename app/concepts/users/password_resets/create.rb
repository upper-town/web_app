# frozen_string_literal: true

module Users
  module PasswordResets
    class Create
      attr_reader :password_reset, :request, :rate_limiter

      def initialize(password_reset, request)
        @password_reset = password_reset
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_password_resets_create:#{request.remote_ip}",
          2,
          5.minutes,
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

        user = find_user

        schedule_email(user) if user

        Result.success
      end

      private

      def find_user
        User.find_by(email: password_reset.email)
      end

      def schedule_email(user)
        Users::PasswordResets::EmailJob.perform_async(user.id)
      end
    end
  end
end
