# frozen_string_literal: true

module ServerWebhooks
  module EventPayloads
    class ServerVotesCreate
      def initialize(server_vote)
        @server_vote = server_vote
      end

      def call
        {
          'server_vote' => {
            'id'              => @server_vote.suuid,
            'reference'       => @server_vote.reference,
            'remote_ip'       => @server_vote.remote_ip,
            'server_id'       => @server_vote.server.suuid,
            'app_id'          => @server_vote.app.suuid,
            'country_code'    => @server_vote.country_code,
            'user_account_id' => @server.user_account.nil? ? nil : @server.user_account.suuid,
            'created_at'      => @server_vote.created_at,
          }
        }
      end
    end
  end
end
