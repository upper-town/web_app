# frozen_string_literal: true

require "test_helper"

class ServerWebhookEventTest < ActiveSupport::TestCase
  let(:described_class) { ServerWebhookEvent }

  describe "associations" do
    it "belongs to server" do
      server_webhook_event = create_server_webhook_event

      assert(server_webhook_event.server.present?)
    end

    it "belongs to config optionally" do
      server_webhook_event = create_server_webhook_event(config: nil)

      assert(server_webhook_event.config.blank?)

      server_webhook_config = create_server_webhook_config
      server_webhook_event = create_server_webhook_event(config: server_webhook_config)

      assert_equal(server_webhook_config, server_webhook_event.config)
    end
  end

  describe "validations" do
    it "validates status" do
      server_webhook_event = build_server_webhook_event(status: " ")
      server_webhook_event.validate
      assert(server_webhook_event.errors.of_kind?(:status, :blank))

      server_webhook_event = build_server_webhook_event(status: "aaaaaaaa")
      server_webhook_event.validate
      assert(server_webhook_event.errors.of_kind?(:status, :inclusion))

      server_webhook_event = build_server_webhook_event(status: "pending")
      server_webhook_event.validate
      assert_not(server_webhook_event.errors.key?(:status))
    end
  end

  describe "#pending?" do
    describe "when status is pending" do
      it "returns true" do
        server_webhook_event = build_server_webhook_event(status: "pending")

        assert(server_webhook_event.pending?)
      end
    end

    describe "when status is not pending" do
      it "returns false" do
        server_webhook_event = build_server_webhook_event(status: "failed")

        assert_not(server_webhook_event.pending?)
      end
    end
  end

  describe "#retry?" do
    describe "when status is retry" do
      it "returns true" do
        server_webhook_event = build_server_webhook_event(status: "retry")

        assert(server_webhook_event.retry?)
      end
    end

    describe "when status is not retry" do
      it "returns false" do
        server_webhook_event = build_server_webhook_event(status: "failed")

        assert_not(server_webhook_event.retry?)
      end
    end
  end

  describe "#delivered?" do
    describe "when status is delivered" do
      it "returns true" do
        server_webhook_event = build_server_webhook_event(status: "delivered")

        assert(server_webhook_event.delivered?)
      end
    end

    describe "when status is not delivered" do
      it "returns false" do
        server_webhook_event = build_server_webhook_event(status: "failed")

        assert_not(server_webhook_event.delivered?)
      end
    end
  end

  describe "#failed?" do
    describe "when status is failed" do
      it "returns true" do
        server_webhook_event = build_server_webhook_event(status: "failed")

        assert(server_webhook_event.failed?)
      end
    end

    describe "when status is not failed" do
      it "returns false" do
        server_webhook_event = build_server_webhook_event(status: "pending")

        assert_not(server_webhook_event.failed?)
      end
    end
  end

  describe "#maxed_failed_attempts?" do
    describe "when failed_attempts is equal to the limit" do
      it "returns true" do
        server_webhook_event = create_server_webhook_event(
          failed_attempts: described_class::MAX_FAILED_ATTEMPTS
        )

        assert(server_webhook_event.maxed_failed_attempts?)
      end
    end

    describe "when failed_attempts is greater than the limit" do
      it "returns true" do
        server_webhook_event = create_server_webhook_event(
          failed_attempts: 26
        )

        assert(server_webhook_event.maxed_failed_attempts?)
      end
    end

    describe "when failed_attempts is less than the limit" do
      it "returns false" do
        server_webhook_event = create_server_webhook_event(
          failed_attempts: 24
        )

        assert_not(server_webhook_event.maxed_failed_attempts?)
      end
    end
  end

  describe "#retry_in" do
    describe "when status is not retry" do
      it "returns nil" do
        server_webhook_event = create_server_webhook_event(status: "pending")

        assert_nil(server_webhook_event.retry_in)
      end
    end

    describe "when status is retry" do
      it "returns seconds based on failed_attempts" do
        server_webhook_event = create_server_webhook_event(
          status: "retry",
          failed_attempts: 12
        )

        called = 0
        SecureRandom.stub(:rand, ->(arg) do
          called += 1
          assert_equal(10, arg)
          5
        end) do
          assert_equal(20856, server_webhook_event.retry_in)
        end
        assert_equal(1, called)
      end
    end
  end
end
