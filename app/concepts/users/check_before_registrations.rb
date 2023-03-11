# frozen_string_literal: true

module Users
  class CheckBeforeRegistrations
    def initialize(captcha, request)
      @captcha = captcha
      @request = request

      @rate_limiter = Users::RegistrationsRateLimiter.build(@request)
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
