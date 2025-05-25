# frozen_string_literal: true

module Users
  module PasswordResets
    class Create
      include Callable

      attr_reader :password_reset

      def initialize(password_reset)
        @password_reset = password_reset
      end

      def call
        user = find_user
        enqueue_email_job(user) if user

        Result.success
      end

      private

      def find_user
        User.find_by(email: password_reset.email)
      end

      def enqueue_email_job(user)
        Users::PasswordResets::EmailJob.perform_later(user)
      end
    end
  end
end
