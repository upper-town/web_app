# frozen_string_literal: true

module Users
  module Confirmation
    class EmailJob
      include Sidekiq::Job

      sidekiq_options(lock: :while_executing)

      def perform(user_id)
        user = User.find(user_id)

        user.regenerate_token!(:confirmation)
        user.update!(confirmation_sent_at: Time.current)

        UsersMailer
          .with(
            email: user.email,
            confirmation_token: user.current_token(:confirmation)
          )
          .confirmation
          .deliver_now
      end
    end
  end
end
