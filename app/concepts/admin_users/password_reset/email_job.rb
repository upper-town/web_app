# frozen_string_literal: true

module AdminUsers
  module PasswordReset
    class EmailJob
      include Sidekiq::Job

      sidekiq_options(lock: :while_executing)

      def perform(admin_user_id)
        admin_user = AdminUser.find(admin_user_id)

        admin_user.regenerate_token!(:password_reset)
        admin_user.update!(password_reset_sent_at: Time.current)

        AdminUsersMailer
          .with(
            email: admin_user.email,
            password_reset_token: admin_user.current_token(:password_reset)
          )
          .password_reset
          .deliver_now
      end
    end
  end
end
