# frozen_string_literal: true

module AdminUsers
  module PasswordsRateLimiter
    def self.build(request)
      RateLimiting::BasicRateLimiter.new(
        "admin_users_passwords:#{request.remote_ip}",
        5,
        10.minutes.to_i,
        'You have tried to send passwords reset instructions too many times.'
      )
    end
  end
end
