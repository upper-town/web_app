# frozen_string_literal: true

module Seeds
  class CreateAdminUsers
    include Callable

    def call
      AdminUser.insert_all(super_admin_user_hashes)

      result = AdminUser.insert_all(admin_user_hashes)
      result.rows.flatten # admin_user_ids
    end

    private

    def super_admin_user_hashes
      [
        {
          id: 11,
          email: "super.admin.user1@#{AppUtil.web_app_host}",
          password_digest: Seeds::Common.encrypt_password("testpass"),
          email_confirmed_at: Time.current
        },
        {
          id: 22,
          email: "super.admin.user2@#{AppUtil.web_app_host}",
          password_digest: Seeds::Common.encrypt_password("testpass"),
          email_confirmed_at: Time.current
        }
      ]
    end

    def admin_user_hashes
      1.upto(10).map do |n|
        {
          email: "admin.user#{n}@#{AppUtil.web_app_host}",
          password_digest: Seeds::Common.encrypt_password("testpass"),
          email_confirmed_at: Time.current
        }
      end
    end
  end
end
