# frozen_string_literal: true

module Users
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
      user = User.find_or_initialize_by(email:)

      if user.valid?
        ActiveRecord::Base.transaction do
          user.save! unless user.persisted?
          user.create_account! unless user.account.present?
        end

        EmailConfirmations::EmailJob.perform_later(user)
        Result.success(user:)
      else
        Result.failure(user.errors)
      end
    end
  end
end
