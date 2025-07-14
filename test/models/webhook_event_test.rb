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
  end

  describe "validations" do
    it "validates status" do
      webhook_event = build_webhook_event(status: " ")
      webhook_event.validate
      assert(webhook_event.errors.of_kind?(:status, :blank))

      webhook_event = build_webhook_event(status: "aaaaaaaa")
      webhook_event.validate
      assert(webhook_event.errors.of_kind?(:status, :inclusion))

      webhook_event = build_webhook_event(status: "pending")
      webhook_event.validate
      assert_not(webhook_event.errors.key?(:status))
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

  describe "#pending?" do
    describe "when status is pending" do
      it "returns true" do
        webhook_event = build_webhook_event(status: "pending")

        assert(webhook_event.pending?)
      end
    end

    describe "when status is not pending" do
      it "returns false" do
        webhook_event = build_webhook_event(status: "failed")

        assert_not(webhook_event.pending?)
      end
    end
  end

  describe "#retry?" do
    describe "when status is retry" do
      it "returns true" do
        webhook_event = build_webhook_event(status: "retry")

        assert(webhook_event.retry?)
      end
    end

    describe "when status is not retry" do
      it "returns false" do
        webhook_event = build_webhook_event(status: "failed")

        assert_not(webhook_event.retry?)
      end
    end
  end

  describe "#delivered?" do
    describe "when status is delivered" do
      it "returns true" do
        webhook_event = build_webhook_event(status: "delivered")

        assert(webhook_event.delivered?)
      end
    end

    describe "when status is not delivered" do
      it "returns false" do
        webhook_event = build_webhook_event(status: "failed")

        assert_not(webhook_event.delivered?)
      end
    end
  end

  describe "#failed?" do
    describe "when status is failed" do
      it "returns true" do
        webhook_event = build_webhook_event(status: "failed")

        assert(webhook_event.failed?)
      end
    end

    describe "when status is not failed" do
      it "returns false" do
        webhook_event = build_webhook_event(status: "pending")

        assert_not(webhook_event.failed?)
      end
    end
  end

  describe "#maxed_failed_attempts?" do
    describe "when failed_attempts is equal to the limit" do
      it "returns true" do
        webhook_event = create_webhook_event(
          failed_attempts: described_class::MAX_FAILED_ATTEMPTS
        )

        assert(webhook_event.maxed_failed_attempts?)
      end
    end

    describe "when failed_attempts is greater than the limit" do
      it "returns true" do
        webhook_event = create_webhook_event(
          failed_attempts: 26
        )

        assert(webhook_event.maxed_failed_attempts?)
      end
    end

    describe "when failed_attempts is less than the limit" do
      it "returns false" do
        webhook_event = create_webhook_event(
          failed_attempts: 24
        )

        assert_not(webhook_event.maxed_failed_attempts?)
      end
    end
  end

  describe "#retry_in" do
    describe "when status is not retry" do
      it "returns nil" do
        webhook_event = create_webhook_event(status: "pending")

        assert_nil(webhook_event.retry_in)
      end
    end

    describe "when status is retry" do
      it "returns seconds based on failed_attempts" do
        webhook_event = create_webhook_event(
          status: "retry",
          failed_attempts: 12
        )

        called = 0
        SecureRandom.stub(:rand, ->(arg) do
          called += 1
          assert_equal(10, arg)
          5
        end) do
          assert_equal(20856, webhook_event.retry_in)
        end
        assert_equal(1, called)
      end
    end
  end
end
