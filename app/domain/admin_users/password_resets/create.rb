# frozen_string_literal: true

module AdminUsers
  module PasswordResets
    class Create
      include Callable

      class Result < ApplicationResult
        attribute :admin_user
      end

      attr_reader :email

      def initialize(email)
        @email = email
      end

      def call
        admin_user = AdminUser.find_by(email:)

        if !admin_user
          Result.failure(:admin_user_not_found)
        else
          PasswordResets::EmailJob.perform_later(admin_user)
          Result.success(admin_user:)
        end
      end
    end
  end
end
