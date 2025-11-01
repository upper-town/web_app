# frozen_string_literal: true

module Seeds
  class Runner
    include Callable

    def call
      admin_user_ids = CreateAdminUsers.call
      _admin_account_ids = CreateAdminAccounts.call(admin_user_ids)

      user_ids = CreateUsers.call
      _account_ids = CreateAccounts.call(user_ids)

      game_ids = CreateGames.call
      _server_ids = CreateServers.call(game_ids)

      _webhook_config_ids = CreateWebhookConfigs.call
    end
  end
end
