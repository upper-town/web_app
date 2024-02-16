# frozen_string_literal: true

module Users
  module PasswordReset
    class Create
      def initialize(attributes, request)
        @attributes = attributes
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_password_reset_create:#{@request.remote_ip}",
          2,
          5.minutes.to_i,
        )
      end

      def call
        result = @rate_limiter.call
        return result if result.failure?

        user = find_user

        schedule_email(user) if user

        Result.success
      end

      private

      def find_user
        User.find_by(email: @attributes['email'])
      end

      def schedule_email(user)
        Users::PasswordReset::EmailJob.perform_async(user.id)
      end
    end
  end
end
