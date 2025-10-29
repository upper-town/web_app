# frozen_string_literal: true

module Seeds
  class CreateAccounts
    include Callable

    attr_reader :user_ids

    def initialize(user_ids)
      @user_ids = user_ids
    end

    def call
      Account.insert_all(demo_account_hashes)

      result = Account.insert_all(account_hashes)
      result.rows.flatten # account_ids
    end

    private

    def demo_account_hashes
      [
        {
          id: 101,
          user_id: 101,
          uuid: "11111111-1111-1111-1111-111111111111"
        },
        {
          id: 202,
          user_id: 202,
          uuid: "22222222-2222-2222-2222-222222222222"
        }
      ]
    end

    def account_hashes
      user_ids.map do |user_id|
        { user_id: }
      end
    end
  end
end
