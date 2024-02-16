# frozen_string_literal: true

module Users
  class CountSignInAttemptsJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing, on_conflict: :reschedule)

    def perform(user_email, succeeded)
      user = User.find_by(email: user_email)
      return unless user

      if succeeded
        user.increment(:sign_in_count)
      else
        user.increment(:failed_attempts)
      end
    end
  end
end
