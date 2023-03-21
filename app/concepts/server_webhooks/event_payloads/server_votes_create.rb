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
            'user_account_id' => user_account_id,
            'created_at'      => @server_vote.created_at,
          }
        }
      end

      private

      def user_account_id
        return if @server_vote.user_account.nil?

        @server_vote.user_account.suuid
      end
    end
  end
end
