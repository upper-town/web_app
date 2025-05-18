# frozen_string_literal: true

module Users
  module ChangeEmailConfirmations
    class EmailJob < ApplicationJob
      queue_as "critical"
      # TODO: rewrite lock: :while_executing)

      def perform(user)
        change_email_reversion_token, change_email_confirmation_token = update_and_generate_tokens(user)

        UsersMailer
          .with(
            email: user.email,
            change_email: user.change_email,
            change_email_reversion_token: change_email_reversion_token
          )
          .change_email_reversion
          .deliver_now

        UsersMailer
          .with(
            email: user.email,
            change_email: user.change_email,
            change_email_confirmation_token: change_email_confirmation_token
          )
          .change_email_confirmation
          .deliver_now
      end

      private

      def update_and_generate_tokens(user)
        current_time = Time.current

        ActiveRecord::Base.transaction do
          change_email_reversion_token = user.generate_token!(
            :change_email_reversion, 30.days, { email: user.email }
          )
          change_email_confirmation_token = user.generate_token!(
            :change_email_confirmation, nil, { change_email: user.change_email }
          )
          user.update!(
            change_email_reversion_sent_at: current_time,
            change_email_confirmation_sent_at: current_time
          )

          [
            change_email_reversion_token,
            change_email_confirmation_token
          ]
        end
      end
    end
  end
end
