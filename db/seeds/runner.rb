# frozen_string_literal: true

module Seeds
  class Runner
    prepend Callable

    def call
      admin_user_ids = CreateAdminUsers.call
      _admin_account_ids = CreateAdminAccounts.call(admin_user_ids)

      user_ids = CreateUsers.call
      _account_ids = CreateAccounts.call(user_ids)

      game_ids = CreateGames.call
      _server_ids = CreateServers.call(game_ids)
    end
  end
end
