# frozen_string_literal: true

module Users
  module PasswordReset
    class Update
      def initialize(attributes, request)
        @attributes = attributes
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_password_reset:#{@request.remote_ip}",
          2,
          5.minutes.to_i,
        )
      end

      def call
        result = @rate_limiter.call
        return result if result.failure?

        user = find_user

        if user
          reset_password(user)
        else
          Result.failure('Invalid or expired token')
        end
      end

      private

      def find_user
        User.find_by_token(:password_reset, @attributes['token'])
      end

      def reset_password(user)
        if user.invalid?
          return Result.failure(user.errors, user: user)
        end

        begin
          ActiveRecord::Base.transaction do
            user.reset_password!(@attributes['password'])
            user.regenerate_token!(:password_reset)
          end
        rescue ActiveRecord::RecordInvalid => e
          return Result.failure(e.record.errors, user: user)
        rescue StandardError => e
          @rate_limiter.uncall
          raise e
        end

        Result.success(user: user)
      end
    end
  end
end
