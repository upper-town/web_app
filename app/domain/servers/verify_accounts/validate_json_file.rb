# frozen_string_literal: true

module Servers
  module VerifyAccounts
    class ValidateJsonFile
      JSON_FILE_MAX_ACCOUNTS_SIZE = 10
      JSON_FILE_SCHEMA = {
        "id" => "/uppertown.json",
        "type" => "object",
        "required" => [
          "accounts"
        ],
        "properties" => {
          "accounts" => {
            "type" => "array",
            "items" => {
              "type" => "string"
            }
          }
        }
      }
      UUID_PATTERN = /\A(0x)?[0-9a-f]{8}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{12}\z/i

      attr_reader :data, :errors

      def initialize(data)
        @data = data
        @errors = [:not_yet_validated]
      end

      def valid?
        errors.clear

        validate_schema
        if errors.empty?
          validate_accounts_size
          validate_accounts_format
          validate_accounts_uniq
        end

        errors.empty?
      end

      def invalid?
        !valid?
      end

      private

      def validate_schema
        unless JSON::Validator.validate(JSON_FILE_SCHEMA, data)
          @errors << :json_schema_invalid
        end
      end

      def validate_accounts_size
        if data["accounts"].size > JSON_FILE_MAX_ACCOUNTS_SIZE
          @errors << "must be an array with max size of #{JSON_FILE_MAX_ACCOUNTS_SIZE}"
        end
      end

      def validate_accounts_format
        if data["accounts"].any? { |str| !str.match?(UUID_PATTERN) }
          @errors << "must contain valid Account UUIDs"
        end
      end

      def validate_accounts_uniq
        if data["accounts"].size != data["accounts"].uniq.size
          @errors << "must be an array with non-duplicated Account UUIDs"
        end
      end
    end
  end
end
