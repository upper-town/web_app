# frozen_string_literal: true

require "test_helper"

class Webhooks::DeleteOldEventsJobTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::DeleteOldEventsJob }

  describe "#perform" do
    it "deletes events in final statuses that have not been updated in the last 3 months" do
      travel_to("2023-06-01T12:50:10Z") do
        pending_event1 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::PENDING, updated_at: "2023-05-01"))
        pending_event2 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::PENDING, updated_at: "2023-01-01"))

        queued_event1 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::QUEUED, updated_at: "2023-05-01"))
        queued_event2 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::QUEUED, updated_at: "2023-01-01"))

        failed_event1 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::FAILED,  updated_at: "2023-05-01"))
        failed_event2 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::FAILED,  updated_at: "2023-03-01T12:50:11"))
        _failed_event3 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::FAILED, updated_at: "2023-03-01T12:50:10"))
        _failed_event4 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::FAILED, updated_at: "2023-01-01"))
        failed_event5 = create_webhook_event(batch: nil)

        delivered_event1 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::DELIVERED,  updated_at: "2023-05-01"))
        delivered_event2 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::DELIVERED,  updated_at: "2023-03-01T12:50:11"))
        _delivered_event3 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::DELIVERED, updated_at: "2023-03-01T12:50:10"))
        _delivered_event4 = create_webhook_event(batch: create_webhook_batch(status: WebhookBatch::DELIVERED, updated_at: "2023-01-01"))
        delivered_event5 = create_webhook_event(batch: nil)

        described_class.new.perform

        assert_equal(
          [
            pending_event1,
            pending_event2,
            queued_event1,
            queued_event2,
            failed_event1,
            failed_event2,
            failed_event5,
            delivered_event1,
            delivered_event2,
            delivered_event5
          ].sort,
          WebhookEvent.all.sort
        )
      end
    end
  end
end
