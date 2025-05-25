# frozen_string_literal: true

module AdminUsers
  module PasswordResets
    class Create
      include Callable

      attr_reader :password_reset

      def initialize(password_reset)
        @password_reset = password_reset
      end

      def call
        admin_user = find_admin_user
        enqueue_email_job(admin_user) if admin_user

        Result.success
      end

      private

      def find_admin_user
        AdminUser.find_by(email: password_reset.email)
      end

      def enqueue_email_job(admin_user)
        AdminUsers::PasswordResets::EmailJob.perform_later(admin_user)
      end
    end
  end
end
