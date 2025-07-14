# frozen_string_literal: true

require "test_helper"

class Webhooks::DeleteOldEventsJobTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::DeleteOldEventsJob }

  describe "#perform" do
    it "deletes events in final statuses that have not been updated in the last 3 months" do
      travel_to("2023-06-01T12:50:10Z") do
        pending_event_1 = create_webhook_event(status: WebhookEvent::PENDING, updated_at: "2023-05-01")
        pending_event_2 = create_webhook_event(status: WebhookEvent::PENDING, updated_at: "2023-01-01")

        retry_event_1 = create_webhook_event(status: WebhookEvent::RETRY, updated_at: "2023-05-01")
        retry_event_2 = create_webhook_event(status: WebhookEvent::RETRY, updated_at: "2023-01-01")

        failed_event_1 = create_webhook_event(status: WebhookEvent::FAILED, updated_at: "2023-05-01")
        failed_event_2 = create_webhook_event(status: WebhookEvent::FAILED, updated_at: "2023-03-01T12:50:11")
        _failed_event_3 = create_webhook_event(status: WebhookEvent::FAILED, updated_at: "2023-03-01T12:50:10")
        _failed_event_4 = create_webhook_event(status: WebhookEvent::FAILED, updated_at: "2023-01-01")

        delivered_event_1 = create_webhook_event(status: WebhookEvent::DELIVERED, updated_at: "2023-05-01")
        delivered_event_2 = create_webhook_event(status: WebhookEvent::DELIVERED, updated_at: "2023-03-01T12:50:11")
        _delivered_event_3 = create_webhook_event(status: WebhookEvent::DELIVERED, updated_at: "2023-03-01T12:50:10")
        _delivered_event_4 = create_webhook_event(status: WebhookEvent::DELIVERED, updated_at: "2023-01-01")

        described_class.new.perform

        assert_equal(
          [
            pending_event_1,
            pending_event_2,
            retry_event_1,
            retry_event_2,
            failed_event_1,
            failed_event_2,
            delivered_event_1,
            delivered_event_2
          ].sort,
          WebhookEvent.all.sort
        )
      end
    end
  end
end
