# frozen_string_literal: true

require "test_helper"

class ServerWebhooks::UpdateDeliveredEventJobTest < ActiveSupport::TestCase
  let(:described_class) { ServerWebhooks::UpdateDeliveredEventJob }

  describe "#perform" do
    it "updates its notice and status" do
      server_webhook_event = create_server_webhook_event(
        notice: "Some previous notice",
        status: ServerWebhookEvent::RETRY
      )

      described_class.new.perform(server_webhook_event)

      server_webhook_event.reload
      assert_equal("", server_webhook_event.notice)
      assert_equal(ServerWebhookEvent::DELIVERED, server_webhook_event.status)
    end
  end
end
