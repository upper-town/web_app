module Users
  module PasswordResets
    class Update
      attr_reader :password_reset_edit, :request, :rate_limiter

      def initialize(password_reset_edit, request)
        @password_reset_edit = password_reset_edit
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_password_resets_update:#{request.remote_ip}",
          2,
          5.minutes,
          "Too many requests"
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

        user = find_user

        if user
          reset_password(user)
        else
          Result.failure("Invalid or expired token")
        end
      end

      private

      def find_user
        User.find_by_token(:password_reset, password_reset_edit.token)
      end

      def reset_password(user)
        begin
          ActiveRecord::Base.transaction do
            user.reset_password!(password_reset_edit.password)
            user.expire_token!(:password_reset)
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
