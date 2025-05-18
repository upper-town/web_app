module Servers
  module VerifyAccounts
    class CheckJsonFileMetadata
      JSON_FILE_MAX_SIZE = 512
      JSON_FILE_CONTENT_TYPE_PATTERN = %r{\bapplication/json\b}i

      attr_reader :server, :json_file_path, :connection

      def initialize(server, json_file_path)
        @server = server
        @json_file_path = json_file_path

        @connection = build_connection
      end

      def call
        response = connection.head(json_file_path)

        if response.headers["Content-Length"].to_i > JSON_FILE_MAX_SIZE
          Result.failure("JSON file size must not be greater than #{JSON_FILE_MAX_SIZE} bytes")
        elsif !response.headers["Content-Type"].match?(JSON_FILE_CONTENT_TYPE_PATTERN)
          Result.failure("JSON file Content-Type must be application/json")
        else
          Result.success
        end
      rescue Faraday::ClientError, Faraday::ServerError => e
        Result.failure("Request failed: #{e}")
      rescue Faraday::Error => e
        Result.failure("Connection failed: #{e}")
      end

      private

      def build_connection
        Faraday.new(url: server.site_url) do |builder|
          builder.response :raise_error
        end
      end
    end
  end
end
