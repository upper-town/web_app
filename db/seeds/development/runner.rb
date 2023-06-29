# frozen_string_literal: true

module Seeds
  module Development
    class Runner
      def call
        return unless Rails.env.development?

        CleanUp.new.call

        CreateAdminUsers.new.call
        user_ids = CreateUsers.new.call
        user_account_ids = CreateUserAccounts.new(user_ids).call

        app_ids = CreateApps.new.call
        server_ids = CreateServers.new(app_ids).call

        CreateServerUserAccounts.new(server_ids, user_account_ids).call
        CreateServerVotes.new(app_ids, server_ids, user_account_ids).call

        ConsolidateServerVoteCounts.new(server_ids).call
        ConsolidateServerRankingNumbers.new(app_ids).call
      end
    end
  end
end
