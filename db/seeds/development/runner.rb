# frozen_string_literal: true

module Seeds
  module Development
    class Runner
      def call
        return unless Rails.env.development?

        admin_user_ids = CreateAdminUsers.new.call
        _admin_user_account_ids = CreateAdminUserAccounts.new(admin_user_ids).call

        user_ids = CreateUsers.new.call
        user_account_ids = CreateUserAccounts.new(user_ids).call

        game_ids = CreateGames.new.call
        server_ids = CreateServers.new(game_ids).call

        CreateServerUserAccounts.new(server_ids, user_account_ids).call
      end
    end
  end
end
