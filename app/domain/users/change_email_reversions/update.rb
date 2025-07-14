# frozen_string_literal: true

module Users
  module ChangeEmailReversions
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :token, :code, :token_record, :code_record, :user

      def initialize(token, code)
        @token = token
        @code = code
      end

      def call
        if !find_user || !find_token || !find_code
          Result.failure(:invalid_or_expired_token_or_code)
        elsif code_record.data["email"].blank?
          Result.failure(:old_email_not_associated_with_code, user:)
        else
          revert_change_email
        end
      end

      private

      def find_user
        user_by_token = User.find_by_token(:change_email_reversion, token)
        user_by_code  = User.find_by_code(:change_email_reversion, code)

        @user = user_by_token == user_by_code ? user_by_code : nil
      end

      def find_token
        @token_record = Token.find_by_token(token)
      end

      def find_code
        @code_record = Code.find_by_code(code)
      end

      def revert_change_email
        ActiveRecord::Base.transaction do
          user.revert_change_email!(code_record.data["email"])
          token_record.expire!
          code_record.expire!
        end

        Result.success(user:)
      end
    end
  end
end
