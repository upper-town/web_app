# frozen_string_literal: true

module AdminUsers
  module Confirmation
    class Update
      def initialize(attributes, request)
        @attributes = attributes
        @request = request

        @rate_limiter = RateLimiting::BasicRateLimiter.new(
          "admin_users_confirm_update:#{@request.remote_ip}",
          2,
          5.minutes.to_i
        )
      end

      def call
        result = @rate_limiter.call
        return result if result.failure?

        admin_user = find_admin_user

        if !admin_user
          Result.failure('Invalid or expired token.')
        elsif admin_user.confirmed?
          Result.failure('Email address has already been confirmed.', admin_user: admin_user)
        elsif admin_user.unconfirmed_email.blank?
          Result.failure("Admin User doesn't have an unconfirmed email.", admin_user: admin_user)
        else
          confirm(admin_user)
        end
      end

      private

      def find_admin_user
        AdminUser.find_by_token(:confirmation, @attributes['token'])
      end

      def confirm(admin_user)
        if admin_user.invalid?
          return Result.failure(admin_user.errors, admin_user: admin_user)
        end

        begin
          ActiveRecord::Base.transaction do
            admin_user.confirm!
            admin_user.regenerate_token!(:confirmation)
          end
        rescue StandardError => e
          @rate_limiter.uncall
          raise e
        end

        Result.success(admin_user: admin_user)
      end
    end
  end
end
