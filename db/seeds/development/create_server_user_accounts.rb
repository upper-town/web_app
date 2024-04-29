# frozen_string_literal: true

module Seeds
  module Development
    class CreateServerUserAccounts
      attr_reader :server_ids, :user_account_ids

      def initialize(server_ids, user_account_ids)
        @server_ids = server_ids
        @user_account_ids = user_account_ids
      end

      def call
        return unless Rails.env.development?

        result = ServerUserAccount.insert_all(server_user_account_hashes)

        result.rows.flatten # server_user_account_ids
      end

      private

      def server_user_account_hashes
        current_time = Time.current
        server_to_take = server_ids.size / 4

        server_ids.sample(server_to_take).map do |server_id|
          {
            server_id: server_id,
            user_account_id: user_account_ids.sample,
            verified_at: rand(1..4) == 1 ? nil : current_time
          }
        end
      end
    end
  end
end
