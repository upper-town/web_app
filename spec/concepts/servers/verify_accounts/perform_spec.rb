# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::VerifyAccounts::Perform do
  describe '#call' do
    context 'when request to check JSON file metadata times out' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_timeout: true
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, 'Connection failed: execution expired')).to be(true)

        expect(json_file_head_request).to have_been_requested
      end
    end

    context 'when request to check JSON file metadata responds with 5xx status' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 500
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, 'Request failed: the server responded with status 500')).to be(true)

        expect(json_file_head_request).to have_been_requested
      end
    end

    context 'when request to check JSON file metadata responds with 4xx status' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 400
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, 'Request failed: the server responded with status 400')).to be(true)

        expect(json_file_head_request).to have_been_requested
      end
    end

    context 'when request to check JSON file metadata responds with greater Content-Length' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '513' }
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, 'JSON file size must not be greater than 512 bytes')).to be(true)

        expect(json_file_head_request).to have_been_requested
      end
    end

    context 'when request to check JSON file metadata responds with wrong Content-Type' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'text/plain' }
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, 'JSON file Content-Type must be application/json')).to be(true)

        expect(json_file_head_request).to have_been_requested
      end
    end

    context 'when request to download JSON file times out' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          'https://game-server.company.com/upper_town.json',
          response_timeout: true
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, 'Connection failed: execution expired')).to be(true)

        expect(json_file_head_request).to have_been_requested
        expect(json_file_get_request).to have_been_requested
      end
    end

    context 'when request to download JSON file responds with 5xx status' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          'https://game-server.company.com/upper_town.json',
          response_status: 500
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, 'Request failed: the server responded with status 500')).to be(true)

        expect(json_file_head_request).to have_been_requested
        expect(json_file_get_request).to have_been_requested
      end
    end

    context 'when request to download JSON file responds with 4xx status' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          'https://game-server.company.com/upper_town.json',
          response_status: 400
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, 'Request failed: the server responded with status 400')).to be(true)

        expect(json_file_head_request).to have_been_requested
        expect(json_file_get_request).to have_been_requested
      end
    end

    context 'when request to download JSON file fails to parse response body' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' },
          response_body: '{""}'
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors).to have_key(:base)
        expect(result.errors.full_messages).to include(/Invalid JSON file/)

        expect(json_file_head_request).to have_been_requested
        expect(json_file_get_request).to have_been_requested
      end
    end

    context 'when JSON file fails to validate schema' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' },
          response_body: { 'something' => 'else' }.to_json
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors).to be_of_kind(:base, :invalid_json_schema)

        expect(json_file_head_request).to have_been_requested
        expect(json_file_get_request).to have_been_requested
      end
    end

    context 'when JSON file is valid but accounts do not exist for UUIDs' do
      it 'returns failure' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        account1 = create(:account)
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' },
          response_body: {
            'accounts' => [
              account1.uuid,
              'e42d89f7-1b04-4d49-a12b-98b7b210e751',
              '096f9009-9b40-4a2b-88a7-8d74290ff700',
            ]
          }.to_json
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, "Account #{account1.uuid} does not exist")).to be(false)
        expect(result.errors.of_kind?(:base, 'Account e42d89f7-1b04-4d49-a12b-98b7b210e751 does not exist')).to be(true)
        expect(result.errors.of_kind?(:base, 'Account 096f9009-9b40-4a2b-88a7-8d74290ff700 does not exist')).to be(true)

        expect(json_file_head_request).to have_been_requested
        expect(json_file_get_request).to have_been_requested
      end
    end

    context 'when JSON file has an empty list of account UUIDs' do
      it 'returns failure and unverifies existing server_accounts associations' do
        server = create(:server, site_url: 'https://game-server.company.com/')
        existing_server_account1 = create(:server_account, server: server, verified_at: 2.days.ago)
        existing_server_account2 = create(:server_account, server: server, verified_at: 1.day.ago)
        json_file_head_request = stub_json_file_request(
          :head,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' }
        )
        json_file_get_request = stub_json_file_request(
          :get,
          'https://game-server.company.com/upper_town.json',
          response_status: 200,
          response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' },
          response_body: {
            'accounts' => []
          }.to_json
        )

        result = described_class.new(server).call

        expect(result).to be_failure
        expect(result.errors.of_kind?(:base, 'Empty "accounts" array in /upper_town.json')).to be(true)

        expect(existing_server_account1.reload.verified_at).to be_nil
        expect(existing_server_account2.reload.verified_at).to be_nil

        expect(json_file_head_request).to have_been_requested
        expect(json_file_get_request).to have_been_requested
      end
    end

    context 'when everything is correct' do
      it 'returns success and syncs server_accounts associations' do
        freeze_time do
          server = create(:server, site_url: 'https://game-server.company.com/')
          account1 = create(:account)
          account2 = create(:account)
          account3 = create(:account)
          existing_server_account1 = create(:server_account, server: server, account: account1, verified_at: 2.days.ago)
          existing_server_account2 = create(:server_account, server: server, account: account2, verified_at: 1.day.ago)
          json_file_head_request = stub_json_file_request(
            :head,
            'https://game-server.company.com/upper_town.json',
            response_status: 200,
            response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' }
          )
          json_file_get_request = stub_json_file_request(
            :get,
            'https://game-server.company.com/upper_town.json',
            response_status: 200,
            response_headers: { 'Content-Length' => '512', 'Content-Type' => 'application/json' },
            response_body: {
              'accounts' => [
                # Removed account1
                account2.uuid,
                account3.uuid, # Added account3
              ]
            }.to_json
          )

          result = nil
          expect do
            result = described_class.new(server).call
          end.to change(ServerAccount, :count).by(1)

          expect(result).to be_success

          expect(existing_server_account1.reload.verified_at).to be_nil
          expect(existing_server_account2.reload.verified_at).to eq(Time.current)

          new_server_account3 = ServerAccount.last
          expect(new_server_account3.server).to eq(server)
          expect(new_server_account3.account).to eq(account3)
          expect(new_server_account3.verified_at).to eq(Time.current)

          expect(json_file_head_request).to have_been_requested
          expect(json_file_get_request).to have_been_requested
        end
      end
    end
  end

  def stub_json_file_request(
    method,
    url,
    response_status: 200,
    response_headers: { 'Content-Type' => 'application/json' },
    response_body: '{}',
    response_timeout: false
  )
    request = stub_request(method, url)

    if response_timeout
      request.to_timeout
    else
      request.to_return(
        status: response_status,
        headers: response_headers,
        body: response_body,
      )
    end
  end
end
