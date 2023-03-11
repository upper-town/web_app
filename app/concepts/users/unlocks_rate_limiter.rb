# frozen_string_literal: true

module Users
  module UnlocksRateLimiter
    def self.build(request)
      RateLimiting::BasicRateLimiter.new(
        request,
        'users_unlocks',
        3,
        10.minutes.to_i,
        'You have tried to send unlock instructions too many times.'
      )
    end
  end
end
