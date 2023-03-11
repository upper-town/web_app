# frozen_string_literal: true

module Users
  module ConfirmationsRateLimiter
    def self.build(request)
      RateLimiting::BasicRateLimiter.new(
        request,
        'users_confirmations',
        3,
        10.minutes.to_i,
        'You have tried to send confirmation instructions too many times.'
      )
    end
  end
end
