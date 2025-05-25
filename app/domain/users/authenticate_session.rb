# frozen_string_literal: true

module Users
  class AuthenticateSession
    include Callable

    class Result < ApplicationResult
      attribute :user
    end

    attr_reader :session

    def initialize(session)
      @session = session
    end

    def call
      result = check_exists
      return result if result.failure?

      authenticate
    end

    private

    def check_exists
      if User.exists?(email: session.email)
        Result.success
      else
        Result.failure("Incorrect password or email")
      end
    end

    def authenticate
      user = User.authenticate_by(email: session.email, password: session.password)

      if user
        count_attempt(true)
        Result.success(user: user)
      else
        count_attempt(false)
        Result.failure("Incorrect password or email")
      end
    end

    def count_attempt(succeeded)
      Users::CountSignInAttemptsJob.perform_later(session.email, succeeded)
    end
  end
end
