# frozen_string_literal: true

module AdminUsers
  class Create
    attr_reader :email_confirmation, :request, :rate_limiter

    def initialize(email_confirmation, request)
      @email_confirmation = email_confirmation
      @request = request

      @rate_limiter = RateLimiting::BasicRateLimiter.new(
        "admin_users_create:#{request.remote_ip}",
        2,
        5.minutes.to_i,
        'Email confirmation has already been sent.'
      )
    end

    def call
      result = rate_limiter.call
      return result if result.failure?

      result = find_or_create_admin_user
      return result if result.failure?

      admin_user = result.data[:admin_user]

      schedule_email_confirmation_job(admin_user)

      Result.success(admin_user: admin_user)
    end

    private

    def find_or_create_admin_user
      existing_admin_user = AdminUser.find_by(email: email_confirmation.email)
      new_admin_user = AdminUser.new(
        email: email_confirmation.email,
        email_confirmed_at: nil
      )

      admin_user = existing_admin_user || new_admin_user

      if admin_user.persisted?
        Result.success(admin_user: admin_user)
      elsif admin_user.invalid?
        rate_limiter.uncall

        Result.failure(admin_user.errors, admin_user: admin_user)
      else
        begin
          ActiveRecord::Base.transaction do
            admin_user.save!
            admin_user.create_account!
          end

          Result.success(admin_user: admin_user)
        rescue StandardError => e
          rate_limiter.uncall

          raise e
        end
      end
    end

    def schedule_email_confirmation_job(admin_user)
      AdminUsers::EmailConfirmations::Job.set(queue: 'critical').perform_async(admin_user.id)
    end
  end
end
