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
        'Email confirmation has already been sent.'
      )
    end

    def call
      result = rate_limiter.call
      return result if result.failure?

      result = find_or_create_user
      return result if result.failure?

      user = result.data[:user]

      schedule_email_confirmation_job(user)

      Result.success(user: user)
    end

    private

    def find_or_create_user
      existing_user = User.find_by(email: email_confirmation.email)
      new_user = User.new(
        email: email_confirmation.email,
        email_confirmed_at: nil
      )

      user = existing_user || new_user

      if user.persisted?
        Result.success(user: user)
      elsif user.invalid?
        rate_limiter.uncall

        Result.failure(user.errors, user: user)
      else
        begin
          ActiveRecord::Base.transaction do
            user.save!
            user.create_account!
          end

          Result.success(user: user)
        rescue StandardError => e
          rate_limiter.uncall

          raise e
        end
      end
    end

    def schedule_email_confirmation_job(user)
      Users::EmailConfirmations::EmailJob.set(queue: 'critical').perform_async(user.id)
    end
  end
end
