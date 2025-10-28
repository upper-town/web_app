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
      user = find_user
      return Result.failure(:incorrect_password_or_email) unless user

      if authenticate_user
        user.increment!(:sign_in_count)
        Result.success(user:)
      else
        user.increment!(:failed_attempts)
        Result.failure(:incorrect_password_or_email)
      end
    end

    private

    def find_user
      User.find_by(email:)
    end

    def authenticate_user
      User.authenticate_by(email:, password:)
    end
  end
end
