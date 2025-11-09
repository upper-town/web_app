# frozen_string_literal: true

require "test_helper"

class Servers::VerifyAccounts::PerformTest < ActiveSupport::TestCase
  let(:described_class) { Servers::VerifyAccounts::Perform }

  describe "#call" do
    describe "when request to check JSON file metadata times out" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_timeout: true
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Connection failed: execution expired"))

        assert_requested(json_file_head_request)
      end
    end

    describe "when request to check JSON file metadata responds with 5xx status" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 500
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("Request failed: the server responded with status 500") })

        assert_requested(json_file_head_request)
      end
    end

    describe "when request to check JSON file metadata responds with 4xx status" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 400
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("Request failed: the server responded with status 400") })

        assert_requested(json_file_head_request)
      end
    end

    describe "when request to check JSON file metadata responds with greater Content-Length" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "513" }
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("JSON file size must not be greater than 512 bytes") })

        assert_requested(json_file_head_request)
      end
    end

    describe "when request to check JSON file metadata responds with wrong Content-Type" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "text/plain" }
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("JSON file Content-Type must be application/json") })

        assert_requested(json_file_head_request)
      end
    end

    describe "when request to download JSON file times out" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_timeout: true
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("Connection failed: execution expired") })

        assert_requested(json_file_head_request)
        assert_requested(json_file_get_request)
      end
    end

    describe "when request to download JSON file responds with 5xx status" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 500
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("Request failed: the server responded with status 500") })

        assert_requested(json_file_head_request)
        assert_requested(json_file_get_request)
      end
    end

    describe "when request to download JSON file responds with 4xx status" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 400
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("Request failed: the server responded with status 400") })

        assert_requested(json_file_head_request)
        assert_requested(json_file_get_request)
      end
    end

    describe "when request to download JSON file fails to parse response body" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" },
          response_body: '{""}'
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("Invalid JSON file") })

        assert_requested(json_file_head_request)
        assert_requested(json_file_get_request)
      end
    end

    describe "when JSON file fails to validate schema" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" },
          response_body: { "something" => "else" }.to_json
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors.of_kind?(:json_schema_invalid))

        assert_requested(json_file_head_request)
        assert_requested(json_file_get_request)
      end
    end

    describe "when JSON file is valid but accounts do not exist for UUIDs" do
      it "returns failure" do
        server = create_server(site_url: "https://game-server.company.com/")
        account1 = create_account
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" },
          response_body: {
            "accounts" => [
              account1.uuid,
              "e42d89f7-1b04-4d49-a12b-98b7b210e751",
              "096f9009-9b40-4a2b-88a7-8d74290ff700"
            ]
          }.to_json
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert_not(result.errors.of_kind?(:base, "Account #{account1.uuid} does not exist"))
        assert(result.errors.of_kind?(:base, "Account e42d89f7-1b04-4d49-a12b-98b7b210e751 does not exist"))
        assert(result.errors.of_kind?(:base, "Account 096f9009-9b40-4a2b-88a7-8d74290ff700 does not exist"))

        assert_requested(json_file_head_request)
        assert_requested(json_file_get_request)
      end
    end

    describe "when JSON file has an empty list of account UUIDs" do
      it "returns failure and unverifies existing server_accounts associations" do
        server = create_server(site_url: "https://game-server.company.com/")
        existing_server_account1 = create_server_account(server:, verified_at: 2.days.ago)
        existing_server_account2 = create_server_account(server:, verified_at: 1.day.ago)
        json_file_head_request = stub_json_file_request(
          :head,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          "https://game-server.company.com/uppertown_28c62f1f.json",
          response_status: 200,
          response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" },
          response_body: {
            "accounts" => []
          }.to_json
        )

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?('Empty "accounts" array in uppertown_28c62f1f.json') })

        assert_nil(existing_server_account1.reload.verified_at)
        assert_nil(existing_server_account2.reload.verified_at)

        assert_requested(json_file_head_request)
        assert_requested(json_file_get_request)
      end
    end

    describe "when everything is correct" do
      it "returns success and syncs server_accounts associations" do
        freeze_time do
          server = create_server(site_url: "https://game-server.company.com/")
          account1 = create_account
          account2 = create_account
          account3 = create_account
          existing_server_account1 = create_server_account(server:, account: account1, verified_at: 2.days.ago)
          existing_server_account2 = create_server_account(server:, account: account2, verified_at: 1.day.ago)
          json_file_head_request = stub_json_file_request(
            :head,
            "https://game-server.company.com/uppertown_28c62f1f.json",
            response_status: 200,
            response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" }
          )
          json_file_get_request = stub_json_file_request(
            :get,
            "https://game-server.company.com/uppertown_28c62f1f.json",
            response_status: 200,
            response_headers: { "Content-Length" => "512", "Content-Type" => "application/json" },
            response_body: {
              "accounts" => [
                # Removed account1
                account2.uuid,
                account3.uuid # Added account3
              ]
            }.to_json
          )

          result = nil
          assert_difference(-> { ServerAccount.count }, 1) do
            result = described_class.new(server).call
          end

          assert(result.success?)

          assert_nil(existing_server_account1.reload.verified_at)
          assert_equal(Time.current, existing_server_account2.reload.verified_at)

          new_server_account3 = ServerAccount.last
          assert_equal(server, new_server_account3.server)
          assert_equal(account3, new_server_account3.account)
          assert_equal(Time.current, new_server_account3.verified_at)

          assert_requested(json_file_head_request)
          assert_requested(json_file_get_request)
        end
      end
    end
  end

  def stub_json_file_request(
    method,
    url,
    response_status: 200,
    response_headers: { "Content-Type" => "application/json" },
    response_body: "{}",
    response_timeout: false
  )
    request = stub_request(method, url)

    if response_timeout
      request.to_timeout
    else
      request.to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end
  end
end
