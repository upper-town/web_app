# frozen_string_literal: true

module Users
  module PasswordResets
    class Create
      include Callable

      class Result < ApplicationResult
        attribute :user
      end

      attr_reader :email

      def initialize(email)
        @email = email
      end

      def call
        user = User.find_by(email:)

        if !user
          Result.failure(:user_not_found)
        else
          PasswordResets::EmailJob.perform_later(user)
          Result.success(user:)
        end
      end
    end
  end
end
