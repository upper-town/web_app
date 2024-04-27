# frozen_string_literal: true

module Users
  module ChangeEmailConfirmation
    class Create
      attr_reader :attributes, :current_user_email, :request, :rate_limiter

      def initialize(attributes, current_user_email, request)
        @attributes = attributes
        @current_user_email = current_user_email
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_change_email:#{@request.remote_ip}",
          3,
          2.minutes.to_i,
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
        if current_user_email != attributes['email']
          return Result.failure("Incorrect current email address")
        end

        user = User.authenticate_by(email: current_user_email, password: attributes['password'])

        if user
          user.update!(change_email: attributes['change_email'])
          user.unconfirm_change_email!

          schedule_change_email_confirmation_job(user)

          Result.success(user: user)
        else
          Result.failure('Incorrect password')
        end
      end

      def schedule_change_email_confirmation_job(user)
        Users::ChangeEmailConfirmation::Job.perform_in(30.seconds, user.id)
      end
    end
  end
end
