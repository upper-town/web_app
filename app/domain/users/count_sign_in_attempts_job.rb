# frozen_string_literal: true

module Users
  class CountSignInAttemptsJob < ApplicationJob
    queue_as "low"
    limits_concurrency key: ->(user_email, *) { user_email }

    def perform(user_email, succeeded)
      user = User.find_by(email: user_email)
      return unless user

      if succeeded
        user.increment!(:sign_in_count)
      else
        user.increment!(:failed_attempts)
      end
    end
  end
end
