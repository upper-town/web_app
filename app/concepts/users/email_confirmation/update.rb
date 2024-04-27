# frozen_string_literal: true

module Users
  module EmailConfirmation
    class Update
      def initialize(attributes, request)
        @attributes = attributes
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_confirm_update:#{@request.remote_ip}",
          2,
          5.minutes.to_i
        )
      end

      def call
        result = @rate_limiter.call
        return result if result.failure?

        user = find_user

        if !user
          Result.failure('Invalid or expired token.')
        elsif user.confirmed_email?
          Result.failure('Email address has already been confirmed.', user: user)
        else
          confirm(user)
        end
      end

      private

      def find_user
        User.find_by_token(:email_confirmation, @attributes['token'])
      end

      def confirm(user)
        if user.invalid?
          return Result.failure(user.errors, user: user)
        end

        begin
          ActiveRecord::Base.transaction do
            user.confirm_email!
            user.regenerate_token!(:email_confirmation)
          end
        rescue StandardError => e
          @rate_limiter.uncall
          raise e
        end

        Result.success(user: user)
      end
    end
  end
end
