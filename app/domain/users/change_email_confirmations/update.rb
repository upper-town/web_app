# frozen_string_literal: true

module Users
  module ChangeEmailConfirmations
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :token, :code, :user, :token_record, :code_record

      def initialize(token, code)
        @token = token
        @code = code
      end

      def call
        if !find_user || !find_token || !find_code
          Result.failure(:invalid_or_expired_token_or_code)
        elsif user.confirmed_change_email?
          Result.failure(:new_email_address_already_confirmed, user:)
        elsif code_record.data["change_email"].blank? || code_record.data["change_email"] != user.change_email
          Result.failure(:new_email_not_associated_with_code, user:)
        else
          confirm_change_email
        end
      end

      private

      def find_user
        user_by_token = User.find_by_token(:change_email_confirmation, token)
        user_by_code  = User.find_by_code(:change_email_confirmation, code)

        @user = user_by_token == user_by_code ? user_by_code : nil
      end

      def find_token
        @token_record = Token.find_by_token(token)
      end

      def find_code
        @code_record = Code.find_by_code(code)
      end

      def confirm_change_email
        ActiveRecord::Base.transaction do
          user.update!(
            email: code_record.data["change_email"],
            change_email: nil
          )
          user.confirm_change_email!
          user.confirm_email!
          user.expire_token!(:change_email_confirmation)
          user.expire_code!(:change_email_confirmation)
        end

        Result.success(user:)
      end
    end
  end
end
