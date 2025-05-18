module Seeds
  module Development
    class CreateAdminUsers
      PASSWORD = 'testpass'

      def call
        return unless Rails.env.development?

        result = AdminUser.insert_all(normal_admin_user_hashes.append(super_admin_user_hash))

        result.rows.flatten # admin_user_ids
      end

      private

      def normal_admin_user_hashes
        1.upto(10).map do |n|
          {
            email: "admin.user.#{n}@#{ENV.fetch('APP_HOST')}",
            password_digest: Seeds::Common.encrypt_password(PASSWORD),
            email_confirmed_at: Time.current
          }
        end
      end

      def super_admin_user_hash
        {
          email: "super.admin.user@#{ENV.fetch('APP_HOST')}",
          password_digest: Seeds::Common.encrypt_password(PASSWORD),
          email_confirmed_at: Time.current
        }
      end
    end
  end
end
