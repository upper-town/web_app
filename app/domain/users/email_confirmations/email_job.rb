# frozen_string_literal: true

module Users
  module EmailConfirmations
    class EmailJob < ApplicationJob
      queue_as "critical"

      def perform(user)
        email_confirmation_code = user.generate_code!(:email_confirmation)
        user.update!(email_confirmation_sent_at: Time.current)

        UserMailer
          .email_confirmation(user.email, email_confirmation_code)
          .deliver_now
      end
    end
  end
end
