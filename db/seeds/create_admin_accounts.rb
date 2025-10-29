# frozen_string_literal: true

module Seeds
  class CreateAdminAccounts
    include Callable

    attr_reader :admin_user_ids

    def initialize(admin_user_ids)
      @admin_user_ids = admin_user_ids
    end

    def call
      AdminAccount.insert_all(super_admin_account_hashes)

      result = AdminAccount.insert_all(admin_account_hashes)
      result.rows.flatten # account_ids
    end

    private

    def admin_account_hashes
      admin_user_ids.map do |admin_user_id|
        { admin_user_id: }
      end
    end

    def super_admin_account_hashes
      [
        {
          id: 11,
          admin_user_id: 11,
        },
        {
          id: 22,
          admin_user_id: 22,
        }
      ]
    end
  end
end
