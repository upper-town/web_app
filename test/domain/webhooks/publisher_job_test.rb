# frozen_string_literal: true

require "test_helper"

class Webhooks::PublisherJobTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::PublisherJob }

  describe "#perform" do
    it "enqueues PublishJob for WebhookConfig that have unbatched events" do
      webhook_config1 = create_webhook_config
      create_webhook_event(config: webhook_config1, batch: nil)

      webhook_config2 = create_webhook_config(disabled_at: Time.current)
      create_webhook_event(config: webhook_config2, batch: nil)

      webhook_config3 = create_webhook_config
      create_webhook_event(config: webhook_config3, batch: create_webhook_batch(config: webhook_config3))

      _webhook_config4 = create_webhook_config

      webhook_config5 = create_webhook_config
      create_webhook_event(config: webhook_config5, batch: nil)

      described_class.new.perform

      assert_equal(2, enqueued_jobs.count { it[:job] == Webhooks::PublishJob })
      assert_enqueued_with(job: Webhooks::PublishJob, args: [webhook_config1])
      assert_enqueued_with(job: Webhooks::PublishJob, args: [webhook_config5])
    end
  end
end
