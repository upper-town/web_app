# frozen_string_literal: true

module Servers
  module CreateVoteRateLimiter
    def self.build(request, app_id)
      RateLimiting::BasicRateLimiter.new(
        "servers_create_vote:#{app_id}:#{request.remote_ip}",
        1,
        6.hours.to_i,
        'You have already voted for this game or app.'
      )
    end
  end
end
