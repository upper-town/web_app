# frozen_string_literal: true

module Seeds
  module Development
    class CreateUserAccounts
      def initialize(user_ids)
        @user_ids = user_ids
      end

      def call
        return unless Rails.env.development?

        result = UserAccount.insert_all(user_account_hashes)

        result.rows.flatten # user_account_ids
      end

      private

      def user_account_hashes
        @user_ids.map do |user_id|
          {
            uuid: SecureRandom.uuid,
            user_id: user_id
          }
        end
      end
    end
  end
end
