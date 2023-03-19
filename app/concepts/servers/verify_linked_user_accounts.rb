# frozen_string_literal: true

module Servers
  class VerifyLinkedUserAccounts
    TIMEOUT = 60

    JSON_FILE_PATH = '/upper_town.json'
    JSON_FILE_CONTENT_TYPE_PATTERN = %r{\bapplication/json\b}i
    JSON_FILE_MAX_SIZE = 512
    JSON_FILE_MAX_USER_ACCOUNTS_SIZE = 10

    def initialize(server)
      @server = server
    end

    def call(current_time = Time.current)
      result = check_json_file_metadata
      return result if result.failure?

      result = download_and_parse_json_file
      return result if result.failure?

      parsed_body = result.data[:parsed_body]

      result = check_user_accounts_exist(parsed_body['user_accounts'])
      return result if result.failure?

      upsert_server_user_accounts(parsed_body['user_accounts'], current_time)
    end

    private

    def check_json_file_metadata
      connection = Faraday.new(@server.site_url) do |conn|
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

    rescue Faraday::ConnectionFailed => e
      Result.failure("Connection Error: #{e}")
    end

    def download_and_parse_json_file
      connection = Faraday.new(@server.site_url) do |conn|
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

    rescue Faraday::ConnectionFailed => e
      Result.failure("Connection Error: #{e}")
    rescue Faraday::ParsingError, JSON::ParserError, TypeError => e
      Result.failure("Parsing Error: Invalid JSON file: #{e}")
    end

    def check_user_accounts_exist(user_account_suuids)
      result = Result.new

      user_account_suuids.each do |suuid|
        if !UserAccount.exists_by_suuid?(suuid)
          result.add_errors("User Account ID #{suuid} does not exist")
        end
      end

      result
    end

    # rubocop:disable Rails/SkipsModelValidations
    def upsert_server_user_accounts(user_account_suuids, current_time)
      user_account_ids = UserAccount.where_by_suuid(user_account_suuids).pluck(:id)

      if user_account_ids.empty?
        ServerUserAccount
          .where(server: @server)
          .update_all(verified_at: nil)

        return Result.failure("Empty \"user_accounts\" array in #{JSON_FILE_PATH}")
      end

      ActiveRecord::Base.transaction do
        ServerUserAccount
          .where(server: @server)
          .where.not(user_account_id: user_account_ids)
          .update_all(verified_at: nil)

        ServerUserAccount.upsert_all(
          user_account_ids.map do |user_account_id|
            {
              user_account_id: user_account_id,
              server_id: @server.id,
              verified_at: current_time
            }
          end,
          unique_by: [:user_account_id, :server_id]
        )
      end

      Result.success
    end
    # rubocop:enable Rails/SkipsModelValidations

    class JsonFileValidatonContract < ApplicationValidationContract
      json do
        required(:user_accounts).array(:string)
      end

      rule(:user_accounts) do
        if value.size > JSON_FILE_MAX_USER_ACCOUNTS_SIZE
          key.failure("must be an array with max size of #{JSON_FILE_MAX_USER_ACCOUNTS_SIZE}")
        elsif value.any? { |elem| !ShortUuid.valid?(elem) }
          key.failure('must be an array of valid User Account IDs')
        elsif value.size != value.uniq.size
          key.failure('must be an array with non-duplicated User Account IDs')
        end
      end
    end
  end
end
