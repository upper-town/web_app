# frozen_string_literal: true

module Seeds
  module Development
    class CreateAdminUserAccounts
      def initialize(admin_user_ids)
        @admin_user_ids = admin_user_ids
      end

      def call
        return unless Rails.env.development?

        result = AdminUserAccount.insert_all(admin_user_account_hashes)

        result.rows.flatten # user_account_ids
      end

      private

      def admin_user_account_hashes
        @admin_user_ids.map do |admin_user_id|
          {
            uuid: SecureRandom.uuid,
            admin_user_id: admin_user_id
          }
        end
      end
    end
  end
end
