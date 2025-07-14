# frozen_string_literal: true

require "test_helper"

class Webhooks::BuildEventRequestHeadersAndBodyTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::BuildEventRequestHeadersAndBody }

  describe "#call" do
    it "returns request_headers and request_body accordingly" do
      server = create_server
      webhook_config = create_webhook_config(
        source: server,
        secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      )
      webhook_event = create_webhook_event(
        config: webhook_config,
        type: "test.event",
        last_published_at: "2024-09-02T12:00:01Z",
        failed_attempts: 1,
        data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } }
      )

      request_headers, request_body = described_class.new(webhook_event).call

      assert_equal(
        {
          "Content-Type" => "application/json",
          "X-Signature"  => "cd5f32ed780b6fb29ca8e7f9731e90c346668599f0dfb9dad44d461703ed19d2"
        },
        request_headers
      )
      assert_equal(
        {
          "webhook_event" => {
            "type"              => "test.event",
            "data"              => { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
            "last_published_at" => "2024-09-02T12:00:01Z",
            "failed_attempts"   => 1
          }
        }.to_json,
        request_body
      )
    end
  end
end
