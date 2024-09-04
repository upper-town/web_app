# frozen_string_literal: true

module Users
  class AuthenticateSession
    include Callable

    attr_reader :session, :request, :rate_limiter

    def initialize(session, request)
      @session = session
      @request = request

      @rate_limiter = RateLimiting::BasicRateLimiter.new(
        "users_authenticate_session:#{request.remote_ip}",
        3,
        2.minutes,
        'Too many attempts'
      )
    end

    def call
      result = rate_limiter.call
      return result if result.failure?

      result = check_exists
      return result if result.failure?

      authenticate
    end

    private

    def check_exists
      if User.exists?(email: session.email)
        Result.success
      else
        Result.failure('Incorrect password or email')
      end
    end

    def authenticate
      user = User.authenticate_by(email: session.email, password: session.password)

      if user
        count_attempt(true)
        Result.success(user: user)
      else
        count_attempt(false)
        Result.failure('Incorrect password or email')
      end
    end

    def count_attempt(succeeded)
      Users::CountSignInAttemptsJob.perform_async(session.email, succeeded)
    end
  end
end
