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
          id: 101,
          admin_user_id: 101,
        },
        {
          id: 202,
          admin_user_id: 202,
        }
      ]
    end
  end
end
