# frozen_string_literal: true

module Seeds
  module Development
    class CleanUp
      def call
        return unless Rails.env.development?

        # TODO: clean up webhook stuff

        ServerUserAccount.delete_all
        ServerStat.delete_all
        ServerVote.delete_all
        Server.delete_all
        App.delete_all
        UserAccount.delete_all
        User.delete_all

        AdminRolePermission.delete_all
        AdminUserRole.delete_all
        AdminRole.delete_all
        AdminPermission.delete_all
        AdminUser.delete_all
      end
    end
  end
end
