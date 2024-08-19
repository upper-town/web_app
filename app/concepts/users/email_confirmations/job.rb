# frozen_string_literal: true

module Users
  module EmailConfirmations
    class Job
      include Sidekiq::Job

      sidekiq_options(lock: :while_executing)

      def perform(user_id)
        user = User.find(user_id)

        email_confirmation_token = user.regenerate_token!(:email_confirmation)
        user.update!(email_confirmation_sent_at: Time.current)

        UsersMailer
          .with(
            email: user.email,
            email_confirmation_token: email_confirmation_token
          )
          .email_confirmation
          .deliver_now
      end
    end
  end
end
