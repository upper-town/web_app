# frozen_string_literal: true

module AdminUsers
  module PasswordReset
    class Create
      def initialize(attributes, request)
        @attributes = attributes
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "admin_users_password_reset_create:#{@request.remote_ip}",
          2,
          5.minutes.to_i,
        )
      end

      def call
        result = @rate_limiter.call
        return result if result.failure?

        admin_user = find_admin_user

        schedule_email(admin_user) if admin_user

        Result.success
      end

      private

      def find_admin_user
        AdminUser.find_by(email: @attributes['email'])
      end

      def schedule_email(admin_user)
        AdminUsers::PasswordReset::EmailJob.perform_async(admin_user.id)
      end
    end
  end
end
