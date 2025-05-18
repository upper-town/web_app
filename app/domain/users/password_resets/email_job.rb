module Users
  module PasswordResets
    class EmailJob < ApplicationJob
      queue_as "critical"
      # TODO: rewrite lock: :while_executing)

      def perform(user)
        password_reset_token = user.generate_token!(:password_reset)
        user.update!(password_reset_sent_at: Time.current)

        UsersMailer
          .with(
            email: user.email,
            password_reset_token: password_reset_token
          )
          .password_reset
          .deliver_now
      end
    end
  end
end
