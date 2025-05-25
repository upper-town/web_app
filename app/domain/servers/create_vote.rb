# frozen_string_literal: true

module Servers
  class CreateVote
    include Callable

    class Result < ApplicationResult
      attribute :server_vote
    end

    attr_reader :server, :server_vote, :account, :remote_ip

    def initialize(server, server_vote, remote_ip, account = nil)
      @server = server
      @server_vote = server_vote
      @remote_ip = remote_ip
      @account = account
    end

    def call
      server_vote.server = server
      server_vote.game = server.game
      server_vote.country_code = server.country_code
      server_vote.remote_ip = remote_ip
      server_vote.account = account

      if server_vote.invalid?
        return Result.failure(server_vote.errors)
      end

      server_vote.save!

      enqueue_consolidate_vote_counts
      enqueue_server_webhook_event_create

      Result.success(server_vote: server_vote)
    end

    private

    def enqueue_consolidate_vote_counts
      ConsolidateVoteCountsJob
        .set(queue: "critical")
        .perform_later(server_vote.server, "current")
    end

    def enqueue_server_webhook_event_create
      ServerWebhooks::CreateEvents::ServerVoteCreatedJob.perform_later(server_vote)
    end
  end
end
