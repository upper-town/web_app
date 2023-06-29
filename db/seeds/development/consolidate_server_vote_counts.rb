# frozen_string_literal: true

module Seeds
  module Development
    class ConsolidateServerVoteCounts
      def initialize(server_ids)
        @server_ids = server_ids
      end

      def call
        return unless Rails.env.development?

        # Do not consolidate votes for 1/10 of the servers.
        # The idea is to simulate a scenario in which some servers haven't had
        # their votes consolidated yet.
        selected_server_ids = @server_ids.shuffle.drop(@server_ids.size / 10)

        selected_server_ids.each do |server_id|
          Servers::ConsolidateVoteCountsJob.new.perform(server_id, 'all')
        end
      end
    end
  end
end
