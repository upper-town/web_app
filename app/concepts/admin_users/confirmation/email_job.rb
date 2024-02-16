# frozen_string_literal: true

module AdminUsers
  module Confirmation
    class EmailJob
      include Sidekiq::Job

      sidekiq_options(lock: :while_executing)

      def perform(admin_user_id)
        admin_user = AdminUser.find(admin_user_id)

        admin_user.regenerate_token!(:confirmation)
        admin_user.update!(confirmation_sent_at: Time.current)

        AdminUsersMailer
          .with(
            email: admin_user.email,
            confirmation_token: admin_user.current_token(:confirmation)
          )
          .confirmation
          .deliver_now
      end
    end
  end
end
