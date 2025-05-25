# frozen_string_literal: true

module AdminUsers
  module EmailConfirmations
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :admin_user
      end

      attr_reader :email_confirmation_edit

      def initialize(email_confirmation_edit)
        @email_confirmation_edit = email_confirmation_edit
      end

      def call
        admin_user = find_admin_user

        if !admin_user
          Result.failure("Invalid or expired token")
        elsif admin_user.confirmed_email?
          Result.failure("Email address has already been confirmed", admin_user: admin_user)
        else
          confirm_email(admin_user)
        end
      end

      private

      def find_admin_user
        AdminUser.find_by_token(:email_confirmation, email_confirmation_edit.token)
      end

      def confirm_email(admin_user)
        ActiveRecord::Base.transaction do
          admin_user.confirm_email!
          admin_user.expire_token!(:email_confirmation)
        end

        Result.success(admin_user: admin_user)
      end
    end
  end
end
