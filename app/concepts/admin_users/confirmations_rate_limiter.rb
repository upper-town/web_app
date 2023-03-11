# frozen_string_literal: true

module AdminUsers
  module ConfirmationsRateLimiter
    def self.build(request)
      RateLimiting::BasicRateLimiter.new(
        request,
        'admin_users_confirmations',
        3,
        10.minutes.to_i,
        'You have tried to send confirmation instructions too many times.'
      )
    end
  end
end
