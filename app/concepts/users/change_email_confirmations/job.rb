# frozen_string_literal: true

module Users
  module ChangeEmailConfirmations
    class Job
      include Sidekiq::Job

      sidekiq_options(lock: :while_executing)

      def perform(user_id)
        user = User.find(user_id)

        change_email_reversion(user)
        change_email_confirmation(user)
      end

      private

      def change_email_reversion(user)
        change_email_reversion_token = user.regenerate_token!(
          :change_email_reversion,
          30.days,
          { email: user.email }
        )
        user.update!(change_email_reversion_sent_at: Time.current)

        UsersMailer
          .with(
            email: user.email,
            change_email: user.change_email,
            change_email_reversion_token: change_email_reversion_token
          )
          .change_email_reversion
          .deliver_now
      end

      def change_email_confirmation(user)
        change_email_confirmation_token = user.regenerate_token!(
          :change_email_confirmation,
          nil,
          { change_email: user.change_email }
        )
        user.update!(change_email_confirmation_sent_at: Time.current)

        UsersMailer
          .with(
            email: user.email,
            change_email: user.change_email,
            change_email_confirmation_token: change_email_confirmation_token
          )
          .change_email_confirmation
          .deliver_now
      end
    end
  end
end
