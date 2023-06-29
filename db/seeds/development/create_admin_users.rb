# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
module Seeds
  module Development
    class CreateAdminUsers
      PASSWORD = 'testpass'

      def call
        return unless Rails.env.development?

        admin_user_hashes = normal_admin_user_hashes.append(super_admin_user_hash)
        result = AdminUser.insert_all(admin_user_hashes)

        result.rows.flatten # admin_user_ids
      end

      private

      def normal_admin_user_hashes
        1.upto(10).map do |n|
          {
            email: "admin.user.#{n}@#{ENV.fetch('HOST')}",
            encrypted_password: Devise::Encryptor.digest(User, PASSWORD),
            confirmed_at: Time.current
          }
        end
      end

      def super_admin_user_hash
        {
          email: "super.admin.user@#{ENV.fetch('HOST')}",
          encrypted_password: Devise::Encryptor.digest(User, PASSWORD),
          confirmed_at: Time.current
        }
      end
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
