# frozen_string_literal: true

module Users
  module ChangeEmailReversion
    class Update
      attr_reader :attributes, :request, :rate_limiter

      def initialize(attributes, request)
        @attributes = attributes
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_change_email_reversion:#{request.remote_ip}",
          3,
          2.minutes.to_i,
          'Too many attempts.'
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

        user, user_token = find_user_and_token

        if !user || !user_token
          Result.failure('Invalid or expired token.')
        else
          revert_change_email(user, user_token)
        end
      end

      private

      def find_user_and_token
        [
          User.find_by_token(:change_email_reversion, attributes['token']),
          UserToken.find_by(value: attributes['token'])
        ]
      end

      def revert_change_email(user, user_token)
        if user.invalid?
          return Result.failure(user.errors, user: user)
        end

        if user_token.data['email'].blank?
          return Result.failure('Invalid token: new email address is not associated with token')
        end

        begin
          ActiveRecord::Base.transaction do
            user.revert_change_email!(user_token.data['email'])
            user_token.expire!
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
