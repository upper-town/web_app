# frozen_string_literal: true

module Users
  class Create
    def initialize(attributes, request)
      @attributes = attributes
      @request = request

      @rate_limiter = RateLimiting::BasicRateLimiter.new(
        "users_create:#{@request.remote_ip}",
        2,
        5.minutes.to_i,
        'Email confirmation has already been sent.'
      )
    end

    def call
      result = @rate_limiter.call
      return result if result.failure?

      result = find_or_create_user
      return result if result.failure?

      user = result.data[:user]

      schedule_confirmation_email_job(user)

      Result.success(user: user)
    end

    private

    def find_or_create_user
      existing_user = User.find_by(email: @attributes['email'])
      new_user = User.new(
        uuid:  SecureRandom.uuid,
        email: @attributes['email'],
        confirmed_at: nil,
        unconfirmed_email: @attributes['email']
      )

      user = existing_user || new_user

      if user.persisted?
        Result.success(user: user)
      elsif user.invalid?
        @rate_limiter.uncall

        Result.failure(user.errors, user: user)
      else
        begin
          ActiveRecord::Base.transaction do
            user.save!
            user.create_account!(uuid: SecureRandom.uuid)
          end

          Result.success(user: user)
        rescue StandardError => e
          @rate_limiter.uncall

          raise e
        end
      end
    end

    def schedule_confirmation_email_job(user)
      Users::Confirmation::EmailJob.set(queue: 'critical').perform_async(user.id)
    end
  end
end
