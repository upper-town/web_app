# frozen_string_literal: true

require "test_helper"

class WebhookEventTest < ActiveSupport::TestCase
  let(:described_class) { WebhookEvent }

  describe "associations" do
    it "belongs to config" do
      webhook_config = create_webhook_config
      webhook_event = create_webhook_event(config: webhook_config)

      assert_equal(webhook_config, webhook_event.config)
    end

    it "optionally belongs to batch" do
      webhook_event = create_webhook_event

      assert_nil(webhook_event.batch)

      webhook_batch = create_webhook_batch
      webhook_event.update!(batch: webhook_batch)

      assert_equal(webhook_batch, webhook_event.batch)
    end
  end

  describe "validations" do
    it "validates type" do
      webhook_event = build_webhook_event(type: " ")
      webhook_event.validate
      assert(webhook_event.errors.of_kind?(:type, :blank))

      webhook_event = build_webhook_event(type: "aaaaaaaa")
      webhook_event.validate
      assert(webhook_event.errors.of_kind?(:type, :inclusion))

      webhook_event = build_webhook_event(type: "server_vote.created")
      webhook_event.validate
      assert_not(webhook_event.errors.key?(:type))
    end
  end

  describe ".unbatched" do
    it "returns events with webhook_batch_id nil" do
      webhook_event1 = create_webhook_event
      _webhook_event2 = create_webhook_event(batch: create_webhook_batch)
      webhook_event3 = create_webhook_event

      assert_equal(
        [webhook_event1, webhook_event3].sort,
        described_class.unbatched.sort
      )
    end
  end

  describe "#source" do
    it "returns source from config" do
      webhook_event = create_webhook_event

      assert_equal(
        webhook_event.source,
        webhook_event.config.source
      )
    end
  end
end
