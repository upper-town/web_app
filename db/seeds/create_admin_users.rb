# frozen_string_literal: true

module Seeds
  class CreateAdminUsers
    include Callable

    def call
      return unless Rails.env.development?

      result = AdminUser.insert_all(normal_admin_user_hashes.append(super_admin_user_hash))
      result.rows.flatten # admin_user_ids
    end

    private

    def normal_admin_user_hashes
      1.upto(10).map do |n|
        {
          email: "admin_user_#{n}@#{web_app_host}",
          password_digest: Seeds::Common.encrypt_password("testpass"),
          email_confirmed_at: Time.current
        }
      end
    end

    def super_admin_user_hash
      {
        email: "super_admin_user@#{web_app_host}",
        password_digest: Seeds::Common.encrypt_password("testpass"),
        email_confirmed_at: Time.current
      }
    end
  end
end
