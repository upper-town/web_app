# frozen_string_literal: true

module Seeds
  class CreateAdminAccounts
    include Callable

    attr_reader :admin_user_ids

    def initialize(admin_user_ids)
      @admin_user_ids = admin_user_ids
    end

    def call
      return unless Rails.env.development?

      result = AdminAccount.insert_all(admin_account_hashes)
      result.rows.flatten # account_ids
    end

    private

    def admin_account_hashes
      admin_user_ids.map do |admin_user_id|
        { admin_user_id: }
      end
    end
  end
end
