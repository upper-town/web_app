# frozen_string_literal: true

module AdminUsers
  module PasswordResets
    attr_reader :password_reset, :request, :rate_limiter

    class Create
      def initialize(password_reset, request)
        @password_reset = password_reset
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "admin_users_password_resets_create:#{request.remote_ip}",
          2,
          5.minutes
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

        admin_user = find_admin_user

        schedule_email(admin_user) if admin_user

        Result.success
      end

      private

      def find_admin_user
        AdminUser.find_by(email: password_reset.email)
      end

      def schedule_email(admin_user)
        AdminUsers::PasswordResets::EmailJob.perform_async(admin_user.id)
      end
    end
  end
end
