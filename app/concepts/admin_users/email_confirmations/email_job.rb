# frozen_string_literal: true

module AdminUsers
  module EmailConfirmations
    class EmailJob
      include Sidekiq::Job

      sidekiq_options(lock: :while_executing)

      def perform(admin_user_id)
        admin_user = AdminUser.find(admin_user_id)

        email_confirmation_token = admin_user.generate_token!(:email_confirmation)
        admin_user.update!(email_confirmation_sent_at: Time.current)

        AdminUsersMailer
          .with(
            email: admin_user.email,
            email_confirmation_token: email_confirmation_token
          )
          .email_confirmation
          .deliver_now
      end
    end
  end
end
