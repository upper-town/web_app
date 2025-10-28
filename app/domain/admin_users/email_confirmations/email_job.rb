# frozen_string_literal: true

module AdminUsers
  module EmailConfirmations
    class EmailJob < ApplicationJob
      queue_as "critical"

      def perform(admin_user)
        email_confirmation_token = admin_user.generate_token!(:email_confirmation)
        email_confirmation_code = admin_user.generate_code!(:email_confirmation)
        admin_user.update!(email_confirmation_sent_at: Time.current)

        AdminUserMailer
          .email_confirmation(admin_user.email, email_confirmation_token, email_confirmation_code)
          .deliver_now
      end
    end
  end
end
