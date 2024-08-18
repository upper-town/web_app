# frozen_string_literal: true

module Seeds
  module Development
    class CreateServerAccounts
      attr_reader :server_ids, :account_ids

      def initialize(server_ids, account_ids)
        @server_ids = server_ids
        @account_ids = account_ids
      end

      def call
        return unless Rails.env.development?

        result = ServerAccount.insert_all(server_account_hashes)

        result.rows.flatten # server_account_ids
      end

      private

      def server_account_hashes
        current_time = Time.current
        server_to_take = server_ids.size / 4

        server_ids.sample(server_to_take).map do |server_id|
          {
            server_id: server_id,
            account_id: account_ids.sample,
            verified_at: rand(1..4) == 1 ? nil : current_time
          }
        end
      end
    end
  end
end
