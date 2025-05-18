module Seeds
  module Development
    class Runner
      def call
        return unless Rails.env.development?

        admin_user_ids = CreateAdminUsers.new.call
        _admin_account_ids = CreateAdminAccounts.new(admin_user_ids).call

        user_ids = CreateUsers.new.call
        _account_ids = CreateAccounts.new(user_ids).call

        game_ids = CreateGames.new.call
        _server_ids = CreateServers.new(game_ids).call
      end
    end
  end
end
