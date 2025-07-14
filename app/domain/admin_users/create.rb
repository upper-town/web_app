# frozen_string_literal: true

module AdminUsers
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
      admin_user = AdminUser.find_or_initialize_by(email:)

      if admin_user.valid?
        ActiveRecord::Base.transaction do
          admin_user.save! unless admin_user.persisted?
          admin_user.create_account! unless admin_user.account.present?
        end

        EmailConfirmations::EmailJob.perform_later(admin_user)
        Result.success(admin_user:)
      else
        Result.failure(admin_user.errors)
      end
    end
  end
end
