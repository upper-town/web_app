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
      admin_user = find_admin_user
      return Result.failure(:incorrect_password_or_email) unless admin_user

      if authenticate_admin_user
        admin_user.increment!(:sign_in_count)
        Result.success(admin_user:)
      else
        admin_user.increment!(:failed_attempts)
        Result.failure(:incorrect_password_or_email)
      end
    end

    private

    def find_admin_user
      AdminUser.find_by(email:)
    end

    def authenticate_admin_user
      AdminUser.authenticate_by(email:, password:)
    end
  end
end
