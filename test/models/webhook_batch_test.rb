# frozen_string_literal: true

require "test_helper"

class WebhookBatchTest < ActiveSupport::TestCase
  let(:described_class) { WebhookBatch }

  describe "associations" do
    it "belongs to config" do
      webhook_config = create_webhook_config
      webhook_batch = create_webhook_batch(config: webhook_config)

      assert_equal(webhook_config, webhook_batch.config)
    end

    it "has many events" do
      webhook_batch = create_webhook_batch

      assert_empty(webhook_batch.events)

      webhook_event1 = create_webhook_event(batch: webhook_batch)
      webhook_event2 = create_webhook_event(batch: webhook_batch)

      assert_equal(
        [
          webhook_event1,
          webhook_event2
        ].sort,
        webhook_batch.events.sort
      )
    end
  end

  describe "validations" do
    it "validates status" do
      webhook_batch = build_webhook_batch(status: " ")
      webhook_batch.validate
      assert(webhook_batch.errors.of_kind?(:status, :blank))

      webhook_batch = build_webhook_batch(status: "aaaaaaaa")
      webhook_batch.validate
      assert(webhook_batch.errors.of_kind?(:status, :inclusion))

      webhook_batch = build_webhook_batch(status: "pending")
      webhook_batch.validate
      assert_not(webhook_batch.errors.key?(:status))
    end
  end

  describe "#pending?" do
    describe "when status is pending" do
      it "returns true" do
        webhook_batch = build_webhook_batch(status: "pending")

        assert(webhook_batch.pending?)
      end
    end

    describe "when status is not pending" do
      it "returns false" do
        webhook_batch = build_webhook_batch(status: "failed")

        assert_not(webhook_batch.pending?)
      end
    end
  end

  describe "#queued?" do
    describe "when status is queued" do
      it "returns true" do
        webhook_batch = build_webhook_batch(status: "queued")

        assert(webhook_batch.queued?)
      end
    end

    describe "when status is not queued" do
      it "returns false" do
        webhook_batch = build_webhook_batch(status: "failed")

        assert_not(webhook_batch.queued?)
      end
    end
  end

  describe "#delivered?" do
    describe "when status is delivered" do
      it "returns true" do
        webhook_batch = build_webhook_batch(status: "delivered")

        assert(webhook_batch.delivered?)
      end
    end

    describe "when status is not delivered" do
      it "returns false" do
        webhook_batch = build_webhook_batch(status: "failed")

        assert_not(webhook_batch.delivered?)
      end
    end
  end

  describe "#failed?" do
    describe "when status is failed" do
      it "returns true" do
        webhook_batch = build_webhook_batch(status: "failed")

        assert(webhook_batch.failed?)
      end
    end

    describe "when status is not failed" do
      it "returns false" do
        webhook_batch = build_webhook_batch(status: "pending")

        assert_not(webhook_batch.failed?)
      end
    end
  end

  describe "#delivered!" do
    it "updates batch as delivered" do
      webhook_batch = create_webhook_batch(
        status: "pending",
        metadata: { "notice" => "message", "other" => { "1" => "aaaa", "2" => "bbbb" } }
      )

      webhook_batch.delivered!({ "notice" => "message CHANGED", "other" => { "2" => "xxxx" } })

      assert_equal("delivered", webhook_batch.status)
      assert_equal(
        { "notice" => "message CHANGED", "other" => { "1" => "aaaa", "2" => "xxxx" } },
        webhook_batch.metadata
      )
    end
  end

  describe "not_delivered!" do
    it "updates batch as not delivered" do
      webhook_batch = create_webhook_batch(
        status: "pending",
        failed_attempts: 23,
        metadata: { "notice" => "message", "other" => { "1" => "aaaa", "2" => "bbbb" } }
      )

      webhook_batch.not_delivered!({ "notice" => "another error" })

      assert_equal("queued", webhook_batch.status)
      assert_equal(24, webhook_batch.failed_attempts)
      assert_equal(
        { "notice" => "another error", "other" => { "1" => "aaaa", "2" => "bbbb" } },
        webhook_batch.metadata
      )

      webhook_batch.not_delivered!({ "notice" => "too many errors", "other" => { "2" => "xxxx" } })

      assert_equal("failed", webhook_batch.status)
      assert_equal(25, webhook_batch.failed_attempts)
      assert_equal(
        { "notice" => "too many errors", "other" => { "1" => "aaaa", "2" => "xxxx" } },
        webhook_batch.metadata
      )
    end
  end
end
