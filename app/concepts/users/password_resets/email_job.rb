# frozen_string_literal: true

module Users
  module PasswordResets
    class EmailJob
      include Sidekiq::Job

      sidekiq_options(lock: :while_executing)

      def perform(user_id)
        user = User.find(user_id)

        user.regenerate_token!(:password_reset)
        user.update!(password_reset_sent_at: Time.current)

        UsersMailer
          .with(
            email: user.email,
            password_reset_token: user.current_token(:password_reset)
          )
          .password_reset
          .deliver_now
      end
    end
  end
end
