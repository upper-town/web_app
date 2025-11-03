# frozen_string_literal: true

module Webhooks
  module Data
    class ServerVoteCreated
      include Callable

      attr_reader :server_vote

      def initialize(server_vote)
        @server_vote = server_vote
      end

      def call
        {
          "server_vote" => {
            "uuid"         => server_vote.uuid,
            "game_id"      => server_vote.game_id,
            "server_id"    => server_vote.server_id,
            "reference"    => server_vote.reference,
            "remote_ip"    => server_vote.remote_ip,
            "account_uuid" => server_vote.account&.uuid,
            "created_at"   => server_vote.created_at.iso8601
          }
        }
      end
    end
  end
end
