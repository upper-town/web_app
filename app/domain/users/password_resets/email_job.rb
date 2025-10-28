# frozen_string_literal: true

module Users
  module PasswordResets
    class EmailJob < ApplicationJob
      queue_as "critical"

      def perform(user)
        password_reset_code = user.generate_code!(:password_reset)
        user.update!(password_reset_sent_at: Time.current)

        UserMailer
          .password_reset(user.email, password_reset_code)
          .deliver_now
      end
    end
  end
end
