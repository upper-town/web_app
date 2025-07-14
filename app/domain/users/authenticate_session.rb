# frozen_string_literal: true

module Users
  class AuthenticateSession
    include Callable

    class Result < ApplicationResult
      attribute :user
    end

    attr_reader :email, :password

    def initialize(email, password)
      @email = email
      @password = password
    end

    def call
      if user_exists?
        if (user = authenticate_user)
          count_sign_in_attempt(succeeded: true)
          Result.success(user:)
        else
          count_sign_in_attempt(succeeded: false)
          Result.failure(:incorrect_password_or_email)
        end
      else
        Result.failure(:incorrect_password_or_email)
      end
    end

    private

    def user_exists?
      User.exists?(email:)
    end

    def authenticate_user
      User.authenticate_by(email:, password:)
    end

    def count_sign_in_attempt(succeeded:)
      Users::CountSignInAttemptsJob.perform_later(email, succeeded)
    end
  end
end
