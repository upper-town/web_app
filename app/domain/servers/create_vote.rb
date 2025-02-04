# frozen_string_literal: true

module Servers
  class CreateVote
    attr_reader :server, :server_vote, :request, :account, :rate_limiter

    def initialize(server, server_vote, request, account = nil)
      @server = server
      @server_vote = server_vote
      @request = request
      @account = account

      @rate_limiter = RateLimiting::BasicRateLimiter.new(
        "servers_create_vote:#{server.game_id}:#{request.remote_ip}",
        1,
        6.hours,
        'You have already voted for this game'
      )
    end

    def call
      result = rate_limiter.call
      return result if result.failure?

      server_vote.server = server
      server_vote.game = server.game
      server_vote.country_code = server.country_code
      server_vote.remote_ip = request.remote_ip
      server_vote.account = account

      if server_vote.invalid?
        rate_limiter.uncall

        return Result.failure(server_vote.errors)
      end

      begin
        server_vote.save!
      rescue StandardError => e
        rate_limiter.uncall
        raise e
      end

      enqueue_consolidate_vote_counts
      enqueue_server_webhook_event_create

      Result.success(server_vote: server_vote)
    end

    private

    def enqueue_consolidate_vote_counts
      ConsolidateVoteCountsJob
        .set(queue: 'critical')
        .perform_later(server_vote.server, 'current')
    end

    def enqueue_server_webhook_event_create
      ServerWebhooks::CreateEvents::ServerVoteCreatedJob.perform_later(server_vote)
    end
  end
end
