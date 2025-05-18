module AdminUsers
  module PasswordResets
    class Create
      include Callable

      attr_reader :password_reset, :request, :rate_limiter

      def initialize(password_reset, request)
        @password_reset = password_reset
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "admin_users_password_resets_create:#{request.remote_ip}",
          2,
          5.minutes,
          "Too many requests"
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

        admin_user = find_admin_user
        enqueue_email_job(admin_user) if admin_user

        Result.success
      end

      private

      def find_admin_user
        AdminUser.find_by(email: password_reset.email)
      end

      def enqueue_email_job(admin_user)
        AdminUsers::PasswordResets::EmailJob.perform_later(admin_user)
      end
    end
  end
end
