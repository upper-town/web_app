# frozen_string_literal: true

module AdminUsers
  module EmailConfirmation
    class Job
      include Sidekiq::Job

      sidekiq_options(lock: :while_executing)

      def perform(admin_user_id)
        admin_user = AdminUser.find(admin_user_id)

        admin_user.regenerate_token!(:email_confirmation)
        admin_user.update!(email_confirmation_sent_at: Time.current)

        AdminUsersMailer
          .with(
            email: admin_user.email,
            email_confirmation_token: admin_user.current_token(:email_confirmation)
          )
          .email_confirmation
          .deliver_now
      end
    end
  end
end
