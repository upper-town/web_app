# frozen_string_literal: true

module Seeds
  class CreateAccounts
    include Callable

    attr_reader :user_ids

    def initialize(user_ids)
      @user_ids = user_ids
    end

    def call
      return unless Rails.env.development?

      result = Account.insert_all(account_hashes)
      result.rows.flatten # account_ids
    end

    private

    def account_hashes
      user_ids.map do |user_id|
        { user_id: }
      end
    end
  end
end
