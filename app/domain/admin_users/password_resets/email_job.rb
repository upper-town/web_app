# frozen_string_literal: true

module AdminUsers
  module PasswordResets
    class EmailJob < ApplicationJob
      queue_as "critical"
      # TODO: rewrite lock: :while_executing)

      def perform(admin_user)
        password_reset_code = admin_user.generate_code!(:password_reset)
        admin_user.update!(password_reset_sent_at: Time.current)

        AdminUsersMailer
          .with(
            email: admin_user.email,
            password_reset_code: password_reset_code
          )
          .password_reset
          .deliver_now
      end
    end
  end
end
