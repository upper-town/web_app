# frozen_string_literal: true

module Servers
  module VerifyAccounts
    class Perform
      attr_reader :server, :json_file_path

      def initialize(server)
        @server = server
        @json_file_path = "uppertown_#{server.site_url_checksum}.json"
      end

      def call(current_time = Time.current)
        result = CheckJsonFileMetadata.new(server, json_file_path).call
        return result if result.failure?

        result = DownloadAndParseJsonFile.new(server, json_file_path).call
        return result if result.failure?

        parsed_body = result.parsed_body

        result = check_accounts_exist(parsed_body["accounts"])
        return result if result.failure?

        upsert_server_accounts(parsed_body["accounts"], current_time)
      end

      private

      def check_accounts_exist(account_uuids)
        result = Result.new

        account_uuids.each do |uuid|
          if !Account.exists?(uuid:)
            result.add_error("Account #{uuid} does not exist")
          end
        end

        result
      end

      def upsert_server_accounts(account_uuids, current_time)
        account_ids = Account.where(uuid: account_uuids).pluck(:id)

        if account_ids.empty?
          ServerAccount
            .where(server:)
            .update_all(verified_at: nil)

          Result.failure("Empty \"accounts\" array in #{json_file_path}")
        else
          ApplicationRecord.transaction do
            ServerAccount
              .where(server:)
              .where.not(account_id: account_ids)
              .update_all(verified_at: nil)

            ServerAccount.upsert_all(
              account_ids.map do |account_id|
                {
                  account_id:,
                  server_id: server.id,
                  verified_at: current_time
                }
              end,
              unique_by: [:account_id, :server_id]
            )
          end

          Result.success
        end
      end
    end
  end
end
