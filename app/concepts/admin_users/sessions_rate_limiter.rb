# frozen_string_literal: true

module AdminUsers
  module SessionsRateLimiter
    def self.build(request)
      RateLimiting::BasicRateLimiter.new(
        "admin_users_sessions:#{request.remote_ip}",
        20,
        30.minutes.to_i,
        'You have tried to sign in too many times.'
      )
    end
  end
end
