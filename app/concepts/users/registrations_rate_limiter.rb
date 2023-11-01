# frozen_string_literal: true

module Users
  module RegistrationsRateLimiter
    def self.build(request)
      RateLimiting::BasicRateLimiter.new(
        "users_registrations:#{request.remote_ip}",
        20,
        30.minutes.to_i,
        'You have tried to create an account too many times.'
      )
    end
  end
end
