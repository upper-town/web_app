# frozen_string_literal: true

module Users
  class Create
    include Callable

    class Result < ApplicationResult
      attribute :user
    end

    attr_reader :email_confirmation

    def initialize(email_confirmation)
      @email_confirmation = email_confirmation
    end

    def call
      user = find_or_create_user
      enqueue_email_confirmation_job(user)

      Result.success(user: user)
    end

    private

    def find_or_create_user
      user = existing_user || build_user
      return user if user.persisted?

      ActiveRecord::Base.transaction do
        user.save!
        user.create_account!
      end

      user
    end

    def existing_user
      User.find_by(email: email_confirmation.email)
    end

    def build_user
      User.new(
        email: email_confirmation.email,
        email_confirmed_at: nil
      )
    end

    def enqueue_email_confirmation_job(user)
      Users::EmailConfirmations::EmailJob.perform_later(user)
    end
  end
end
