# frozen_string_literal: true

module AdminUsers
  module PasswordResets
    class EmailJob < ApplicationJob
      queue_as "critical"

      def perform(admin_user)
        password_reset_code = admin_user.generate_code!(:password_reset)
        admin_user.update!(password_reset_sent_at: Time.current)

        AdminUserMailer
          .password_reset(admin_user.email, password_reset_code)
          .deliver_now
      end
    end
  end
end
