# frozen_string_literal: true

module Servers
  class VerifyLinkedAccounts
    TIMEOUT = 60

    JSON_FILE_PATH = '/upper_town.json'
    JSON_FILE_CONTENT_TYPE_PATTERN = %r{\bapplication/json\b}i
    JSON_FILE_MAX_SIZE = 512
    JSON_FILE_MAX_ACCOUNTS_SIZE = 10

    attr_reader :server

    def initialize(server)
      @server = server
    end

    def call(current_time = Time.current)
      result = check_json_file_metadata
      return result if result.failure?

      result = download_and_parse_json_file
      return result if result.failure?

      parsed_body = result.data[:parsed_body]

      result = check_accounts_exist(parsed_body['accounts'])
      return result if result.failure?

      upsert_server_accounts(parsed_body['accounts'], current_time)
    end

    private

    def check_json_file_metadata
      connection = Faraday.new(server.site_url) do |conn|
        conn.options.timeout = TIMEOUT
      end
      response = connection.head(JSON_FILE_PATH)

      if !response.success?
        return Result.failure("Unsuccessful HEAD request: HTTP status #{response.status}")
      end

      if response.headers['content-length'].to_i > JSON_FILE_MAX_SIZE
        return Result.failure('JSON file size must not be greater than 512 bytes')
      end

      if !response.headers['content-type'].match?(JSON_FILE_CONTENT_TYPE_PATTERN)
        return Result.failure('JSON file content-type must be application/json')
      end

      Result.success

    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      Result.failure("Connection Failed or Timeout Error: #{e}")
    end

    def download_and_parse_json_file
      connection = Faraday.new(server.site_url) do |conn|
        conn.options.timeout = TIMEOUT
        conn.response(:json)
      end
      response = connection.get(JSON_FILE_PATH)

      if !response.success?
        return Result.failure("Unsuccessful GET request: HTTP status #{response.status}")
      end

      validation_result = JsonFileValidatonContract.new.call(response.body)

      if validation_result.failure?
        return Result.failure("Invalid JSON schema: #{validation_result.errors.to_hash}.")
      end

      Result.success(parsed_body: response.body)

    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      Result.failure("Connection Failed or Timeout Error: #{e}")
    rescue Faraday::ParsingError, JSON::ParserError, TypeError => e
      Result.failure("Parsing Error: Invalid JSON file: #{e}")
    end

    def check_accounts_exist(account_ids)
      result = Result.new

      account_ids.each do |id|
        if !Account.exists?(id)
          result.add_errors("Account ID #{id} does not exist")
        end
      end

      result
    end

    def upsert_server_accounts(account_ids, current_time)
      account_ids = Account.where(id: account_ids).pluck(:id)

      if account_ids.empty?
        ServerAccount
          .where(server: server)
          .update_all(verified_at: nil)

        return Result.failure("Empty \"accounts\" array in #{JSON_FILE_PATH}")
      end

      ApplicationRecord.transaction do
        ServerAccount
          .where(server: server)
          .where.not(account_id: account_ids)
          .update_all(verified_at: nil)

        ServerAccount.upsert_all(
          account_ids.map do |account_id|
            {
              account_id: account_id,
              server_id: server.id,
              verified_at: current_time
            }
          end,
          unique_by: [:account_id, :server_id]
        )
      end

      Result.success
    end

    class JsonFileValidatonContract < ApplicationValidationContract
      json do
        required(:accounts).array(:integer)
      end

      rule(:accounts) do
        if value.size > JSON_FILE_MAX_ACCOUNTS_SIZE
          key.failure("must be an array with max size of #{JSON_FILE_MAX_ACCOUNTS_SIZE}")
        elsif value.size != value.uniq.size
          key.failure('must be an array with non-duplicated Account IDs')
        end
      end
    end
  end
end
