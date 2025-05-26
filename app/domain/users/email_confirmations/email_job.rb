# frozen_string_literal: true

module Users
  module EmailConfirmations
    class EmailJob < ApplicationJob
      queue_as "critical"
      # TODO: rewrite lock: :while_executing)

      def perform(user)
        email_confirmation_code = user.generate_code!(:email_confirmation)
        user.update!(email_confirmation_sent_at: Time.current)

        UsersMailer
          .with(
            email: user.email,
            email_confirmation_code: email_confirmation_code
          )
          .email_confirmation
          .deliver_now
      end
    end
  end
end
