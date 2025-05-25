# frozen_string_literal: true

module AdminUsers
  module PasswordResets
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :admin_user
      end

      attr_reader :password_reset_edit

      def initialize(password_reset_edit)
        @password_reset_edit = password_reset_edit
      end

      def call
        admin_user = find_admin_user

        if admin_user
          reset_password(admin_user)
        else
          Result.failure("Invalid or expired token")
        end
      end

      private

      def find_admin_user
        AdminUser.find_by_token(:password_reset, password_reset_edit.token)
      end

      def reset_password(admin_user)
        ActiveRecord::Base.transaction do
          admin_user.reset_password!(password_reset_edit.password)
          admin_user.expire_token!(:password_reset)
        end

        Result.success(admin_user: admin_user)
      end
    end
  end
end
