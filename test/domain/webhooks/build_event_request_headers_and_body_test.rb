# frozen_string_literal: true

require "test_helper"

class Webhooks::BuildEventRequestHeadersAndBodyTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::BuildEventRequestHeadersAndBody }

  describe "#call" do
    it "returns request_headers and request_body accordingly" do
      webhook_config = create_webhook_config(secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
      webhook_batch = create_webhook_batch(
        config: webhook_config,
        failed_attempts: 5
      )
      create_webhook_event(
        config: webhook_config,
        batch: webhook_batch,
        type: "server_vote.created",
        data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
        created_at: "2025-01-01T12:00:01Z",
        updated_at: "2025-01-01T12:00:11Z"
      )
      create_webhook_event(
        config: webhook_config,
        batch: webhook_batch,
        type: "server_vote.created",
        data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
        created_at: "2025-01-01T12:00:02Z",
        updated_at: "2025-01-01T12:00:22Z"
      )

      request_headers, request_body = described_class.new(webhook_batch).call

      assert_equal(
        {
          "Content-Type" => "application/json",
          "X-Signature"  => "13655a5402705ebf320c612c76555d6cf9f98a35c0a694a6019891f27f3f2b13"
        },
        request_headers
      )
      assert_equal(
        [
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:01.000Z",
            "updated_at" => "2025-01-01T12:00:11.000Z"
          },
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:02.000Z",
            "updated_at" => "2025-01-01T12:00:22.000Z"
          }
        ].to_json,
        request_body
      )
    end
  end
end
