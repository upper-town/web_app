# frozen_string_literal: true

require "test_helper"

class Webhooks::UpdateDeliveredEventJobTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::UpdateDeliveredEventJob }

  describe "#perform" do
    it "updates its metadata.notice and status" do
      webhook_event = create_webhook_event(
        metadata: { notice: "Some previous notice" },
        status: WebhookEvent::RETRY
      )

      described_class.new.perform(webhook_event)

      webhook_event.reload
      assert_equal({}, webhook_event.metadata)
      assert_equal(WebhookEvent::DELIVERED, webhook_event.status)
    end
  end
end
