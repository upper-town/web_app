# frozen_string_literal: true

module AdminUsers
  class AuthenticateSession
    include Callable

    class Result < ApplicationResult
      attribute :admin_user
    end

    attr_reader :email, :password

    def initialize(email, password)
      @email = email
      @password = password
    end

    def call
      if admin_user_exists?
        if (admin_user = authenticate_admin_user)
          count_sign_in_attempt(succeeded: true)
          Result.success(admin_user:)
        else
          count_sign_in_attempt(succeeded: false)
          Result.failure(:incorrect_password_or_email)
        end
      else
        Result.failure(:incorrect_password_or_email)
      end
    end

    private

    def admin_user_exists?
      AdminUser.exists?(email:)
    end

    def authenticate_admin_user
      AdminUser.authenticate_by(email:, password:)
    end

    def count_sign_in_attempt(succeeded:)
      AdminUsers::CountSignInAttemptsJob.perform_later(email, succeeded)
    end
  end
end
