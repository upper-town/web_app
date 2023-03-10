# frozen_string_literal: true

module Servers
  module CreateVoteRateLimiter
    def self.build(request, server_id)
      RateLimiting::BasicRateLimiter.new(
        request,
        "servers_create_vote:#{server_id}",
        1,
        6.hours.to_i,
        'You have already voted for this server.'
      )
    end
  end
end
