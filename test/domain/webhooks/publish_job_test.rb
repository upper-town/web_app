# frozen_string_literal: true

require "test_helper"

class Webhooks::PublishJobTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::PublishJob }

  describe "#perform" do
    it "creates WebhookBatch and enqueues PublishBatchJob for pending batches" do
      webhook_config = create_webhook_config

      webhook_batch1 = create_webhook_batch(config: webhook_config, status: "pending")
      create_webhook_event(config: webhook_config, batch: webhook_batch1)

      webhook_event1 = create_webhook_event(config: webhook_config, batch: nil)
      webhook_event2 = create_webhook_event(config: webhook_config, batch: nil)

      assert_difference(-> { WebhookBatch.count }, 1) do
        described_class.new.perform(webhook_config)
      end

      webhook_batch2 = WebhookBatch.last
      assert_equal(
        [webhook_event1, webhook_event2].sort,
        webhook_batch2.events.sort
      )

      assert(webhook_batch1.reload.queued?)
      assert(webhook_batch2.queued?)

      assert_equal(2, enqueued_jobs.count { it[:job] == Webhooks::PublishBatchJob })
      assert_enqueued_with(job: Webhooks::PublishBatchJob, args: [webhook_batch1])
      assert_enqueued_with(job: Webhooks::PublishBatchJob, args: [webhook_batch2])
    end
  end
end
