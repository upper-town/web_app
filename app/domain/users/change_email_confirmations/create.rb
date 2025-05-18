module Users
  module ChangeEmailConfirmations
    class Create
      include Callable

      attr_reader :change_email_confirmation, :current_user_email, :request, :rate_limiter

      def initialize(change_email_confirmation, current_user_email, request)
        @change_email_confirmation = change_email_confirmation
        @current_user_email = current_user_email
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "users_change_email_confirmations_create:#{@request.remote_ip}",
          3,
          2.minutes,
          "Too many attempts"
        )
      end

      def call
        result = rate_limiter.call
        return result if result.failure?

        if current_user_email != change_email_confirmation.email
          Result.failure("Incorrect current email address")
        else
          authenticate_and_change_user_email
        end
      end

      private

      def authenticate_and_change_user_email
        user = User.authenticate_by(email: current_user_email, password: change_email_confirmation.password)
        return Result.failure("Incorrect password") unless user

        begin
          ActiveRecord::Base.transaction do
            user.update!(change_email: change_email_confirmation.change_email)
            user.unconfirm_change_email!
          end
        rescue StandardError => e
          rate_limiter.uncall

          raise e
        end

        Users::ChangeEmailConfirmations::EmailJob
          .set(wait: 30.seconds)
          .perform_later(user)

        Result.success(user: user)
      end
    end
  end
end
