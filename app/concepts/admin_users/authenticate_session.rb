# frozen_string_literal: true

module AdminUsers
  class AuthenticateSession
    def initialize(attributes, request)
      @attributes = attributes
      @request = request

      @rate_limiter = RateLimiting::BasicRateLimiter.new(
        "admin_users_session_validate:#{@request.remote_ip}",
        3,
        2.minutes.to_i,
        'Too many attempts.'
      )
    end

    def call
      result = @rate_limiter.call
      return result if result.failure?

      find_and_authenticate_admin_user
    end

    private

    def find_and_authenticate_admin_user
      admin_user = AdminUser.authenticate_by(email: @attributes['email'], password: @attributes['password'])

      if admin_user
        count_attempt(true)

        Result.success(admin_user: admin_user)
      else
        count_attempt(false)

        Result.failure('Incorrect password or email')
      end
    end

    def count_attempt(succeeded)
      AdminUsers::CountSignInAttemptsJob.perform_async(@attributes['email'], succeeded)
    end
  end
end
