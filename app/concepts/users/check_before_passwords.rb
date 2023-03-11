# frozen_string_literal: true

module Users
  class CheckBeforePasswords
    def initialize(captcha, request)
      @captcha = captcha
      @request = request

      @rate_limiter = Users::PasswordsRateLimiter.build(@request)
    end

    def call
      # result = @captcha.call(@request)
      # return result if result.failure?

      # result = @rate_limiter.call
      # return result if result.failure?

      Result.success
    end
  end
end
