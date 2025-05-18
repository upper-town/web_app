module AdminUsers
  class Create
    attr_reader :email_confirmation, :request, :rate_limiter

    def initialize(email_confirmation, request)
      @email_confirmation = email_confirmation
      @request = request

      @rate_limiter = RateLimiting::BasicRateLimiter.new(
        "admin_users_create:#{request.remote_ip}",
        2,
        5.minutes,
        "Too many requests"
      )
    end

    def call
      result = rate_limiter.call
      return result if result.failure?

      admin_user = find_or_create_admin_user
      enqueue_email_confirmation_job(admin_user)

      Result.success(admin_user: admin_user)
    end

    private

    def find_or_create_admin_user
      admin_user = existing_admin_user || build_admin_user
      return admin_user if admin_user.persisted?

      begin
        ActiveRecord::Base.transaction do
          admin_user.save!
          admin_user.create_account!
        end

        admin_user
      rescue StandardError => e
        rate_limiter.uncall

        raise e
      end
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
