# frozen_string_literal: true

module Users
  module ChangeEmailConfirmations
    class EmailJob < ApplicationJob
      queue_as "critical"

      def perform(user)
        change_email_reversion_token,
          change_email_reversion_code,
          change_email_confirmation_code = generate_tokens_and_code(user)

        UserMailer
          .change_email_reversion(
            user.email,
            user.change_email,
            change_email_reversion_token,
            change_email_reversion_code
          )
          .deliver_later

        UserMailer
          .change_email_confirmation(
            user.email,
            user.change_email,
            change_email_confirmation_code
          )
          .deliver_later
      end

      private

      def generate_tokens_and_code(user)
        current_time = Time.current

        ActiveRecord::Base.transaction do
          change_email_reversion_token = user.generate_token!(
            :change_email_reversion,
            30.days
          )
          change_email_reversion_code = user.generate_code!(
            :change_email_reversion,
            30.days,
            { email: user.email }
          )
          change_email_confirmation_code = user.generate_code!(
            :change_email_confirmation,
            30.minutes,
            { change_email: user.change_email }
          )

          user.update!(
            change_email_reversion_sent_at: current_time,
            change_email_confirmation_sent_at: current_time
          )

          [
            change_email_reversion_token,
            change_email_reversion_code,
            change_email_confirmation_code
          ]
        end
      end
    end
  end
end
