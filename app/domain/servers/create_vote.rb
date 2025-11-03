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
      if server_vote.persisted?
        return Result.failure(server_vote:)
      end

      server_vote.server = server
      server_vote.game = server.game
      server_vote.remote_ip = remote_ip
      server_vote.account = account

      if server_vote.invalid?
        return Result.failure(server_vote.errors, server_vote:)
      end

      ActiveRecord::Base.transaction do
        server_vote.save!
        Webhooks::CreateEvents.call(server, WebhookEvent::SERVER_VOTE_CREATED, server_vote)
      end

      Result.success(server_vote:)
    end
  end
end
