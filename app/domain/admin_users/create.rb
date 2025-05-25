# frozen_string_literal: true

module AdminUsers
  class Create
    include Callable

    class Result < ApplicationResult
      attribute :admin_user
    end

    attr_reader :email_confirmation

    def initialize(email_confirmation)
      @email_confirmation = email_confirmation
    end

    def call
      admin_user = find_or_create_admin_user
      enqueue_email_confirmation_job(admin_user)

      Result.success(admin_user: admin_user)
    end

    private

    def find_or_create_admin_user
      admin_user = existing_admin_user || build_admin_user
      return admin_user if admin_user.persisted?

      ActiveRecord::Base.transaction do
        admin_user.save!
        admin_user.create_account!
      end

      admin_user
    end

    def existing_admin_user
      AdminUser.find_by(email: email_confirmation.email)
    end

    def build_admin_user
      AdminUser.new(
        email: email_confirmation.email,
        email_confirmed_at: nil
      )
    end

    def enqueue_email_confirmation_job(admin_user)
      AdminUsers::EmailConfirmations::EmailJob.perform_later(admin_user)
    end
  end
end
