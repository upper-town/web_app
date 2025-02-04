# frozen_string_literal: true

module Users
  class Create
    attr_reader :email_confirmation, :request, :rate_limiter

    def initialize(email_confirmation, request)
      @email_confirmation = email_confirmation
      @request = request

      @rate_limiter = RateLimiting::BasicRateLimiter.new(
        "users_create:#{request.remote_ip}",
        2,
        5.minutes,
        'Too many requests'
      )
    end

    def call
      result = rate_limiter.call
      return result if result.failure?

      user = find_or_create_user
      enqueue_email_confirmation_job(user)

      Result.success(user: user)
    end

    private

    def find_or_create_user
      user = existing_user || build_user
      return user if user.persisted?

      begin
        ActiveRecord::Base.transaction do
          user.save!
          user.create_account!
        end

        user
      rescue StandardError => e
        rate_limiter.uncall

        raise e
      end
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
