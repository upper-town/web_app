# frozen_string_literal: true

module Servers
  class CreateVoteRateLimiter
    MAX_COUNT = 1
    EXPIRES_IN = 6.hours.to_i

    def initialize(server_id, remote_ip)
      @server_id = server_id
      @remote_ip = remote_ip

      @key = "sv:#{@server_id}:#{@remote_ip}" # sv: ServerVote
      @redis_client = RateLimiting.build_redis_client
    end

    def call
      replies = @redis_client.multi do |transaction|
        transaction.incr(@key)
        transaction.expire(@key, EXPIRES_IN, nx: true)
        transaction.ttl(@key)
      end

      if replies[0] <= MAX_COUNT
        Result.success
      else
        Result.failure(
          'You have already voted for this server. ' \
          "You can vote again in #{ttl_to_sentence(replies[2])}"
        )
      end
    end

    def uncall
      @redis_client.multi do |transaction|
        transaction.decr(@key)
        transaction.expire(@key, EXPIRES_IN, nx: true)
      end

      Result.success
    end

    private

    def ttl_to_sentence(seconds)
      ActiveSupport::Duration.build(seconds).inspect
    end
  end
end
