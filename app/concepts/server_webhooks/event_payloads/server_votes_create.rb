# frozen_string_literal: true

module ServerWebhooks
  module EventPayloads
    class ServerVotesCreate
      attr_reader :server_vote

      def initialize(server_vote)
        @server_vote = server_vote
      end

      def call
        {
          'server_vote' => {
            'reference'    => server_vote.reference,
            'remote_ip'    => server_vote.remote_ip,
            'server_id'    => server_vote.server_id,
            'game_id'      => server_vote.game_id,
            'country_code' => server_vote.country_code,
            'account_id'   => server_vote.account_id,
            'created_at'   => server_vote.created_at,
          }
        }
      end
    end
  end
end
