# frozen_string_literal: true

module Users
  module PasswordResets
    class EmailJob < ApplicationJob
      queue_as "critical"
      # TODO: rewrite lock: :while_executing)

      def perform(user)
        password_reset_code = user.generate_code!(:password_reset)
        user.update!(password_reset_sent_at: Time.current)

        UsersMailer
          .with(
            email: user.email,
            password_reset_code: password_reset_code
          )
          .password_reset
          .deliver_now
      end
    end
  end
end
