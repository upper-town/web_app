# frozen_string_literal: true

module Seeds
  class CreateAdminUsers
    prepend Callable

    def call
      result = AdminUser.insert_all(normal_admin_user_hashes.append(super_admin_user_hash))
      result.rows.flatten # admin_user_ids
    end

    private

    def normal_admin_user_hashes
      1.upto(10).map do |n|
        {
          email: "admin.user#{n}@#{AppUtil.web_app_host}",
          password_digest: Seeds::Common.encrypt_password("testpass"),
          email_confirmed_at: Time.current
        }
      end
    end

    def super_admin_user_hash
      {
        email: "super.admin.user@#{AppUtil.web_app_host}",
        password_digest: Seeds::Common.encrypt_password("testpass"),
        email_confirmed_at: Time.current
      }
    end
  end
end
