# frozen_string_literal: true

require "test_helper"

class Webhooks::BuildEventRequestHeadersAndBodyTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::BuildEventRequestHeadersAndBody }

  describe "#call" do
    it "returns request_headers and request_body accordingly" do
      webhook_config = create_webhook_config(secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
      webhook_batch = create_webhook_batch(
        config: webhook_config,
        status: "queued",
        failed_attempts: 5
      )
      webhook_event1 = create_webhook_event(
        uuid: "88888888-8888-8888-8888-888888888888",
        config: webhook_config,
        batch: webhook_batch,
        type: "server_vote.created",
        data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
        metadata: {},
        created_at: "2025-01-01T12:00:01Z"
      )
      webhook_event2 = create_webhook_event(
        uuid: "99999999-9999-9999-9999-999999999999",
        config: webhook_config,
        batch: webhook_batch,
        type: "server_vote.created",
        data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
        metadata: {},
        created_at: "2025-01-01T12:00:02Z"
      )

      request_headers, request_body = described_class.new(webhook_batch).call

      assert_equal(
        {
          "Content-Type" => "application/json",
          "X-Signature"  => "3f6d4da98e9ed3d710cb88aa525577900b0f30f75aced80e0ffd5de8b0a76c43"
        },
        request_headers
      )
      assert_equal(
        [
          {
            "uuid" => webhook_event1.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:01.000Z",
          },
          {
            "uuid" => webhook_event2.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:02.000Z",
          }
        ].to_json,
        request_body
      )
    end
  end
end
