# frozen_string_literal: true

module AdminUsers
  class CountSignInAttemptsJob < ApplicationJob
    queue_as 'low'
    # TODO: rewrite lock: :while_executing, on_conflict: :reschedule)

    def perform(admin_user_email, succeeded)
      admin_user = AdminUser.find_by(email: admin_user_email)
      return unless admin_user

      if succeeded
        admin_user.increment!(:sign_in_count)
      else
        admin_user.increment!(:failed_attempts)
      end
    end
  end
end
