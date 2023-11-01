# frozen_string_literal: true

module Users
  module PasswordsRateLimiter
    def self.build(request)
      RateLimiting::BasicRateLimiter.new(
        "users_passwords:#{request.remote_ip}",
        5,
        10.minutes.to_i,
        'You have tried to send passwords reset instructions too many times.'
      )
    end
  end
end
