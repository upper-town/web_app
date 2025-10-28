# frozen_string_literal: true

require "test_helper"

class WebhookConfigTest < ActiveSupport::TestCase
  let(:described_class) { WebhookConfig }

  describe "associations" do
    it "belongs to source" do
      webhook_config = create_webhook_config

      assert(webhook_config.source.present?)
    end

    it "has many events" do
      webhook_config = create_webhook_config

      webhook_event1 = create_webhook_event(config: webhook_config)
      webhook_event2 = create_webhook_event(config: webhook_config)
      _webhook_event3 = create_webhook_event

      assert_equal(
        [webhook_event1, webhook_event2].sort,
        webhook_config.events.sort
      )
    end

    it "has many batches" do
      webhook_config = create_webhook_config

      webhook_batch1 = create_webhook_batch(config: webhook_config)
      webhook_batch2 = create_webhook_batch(config: webhook_config)
      _webhook_batch3 = create_webhook_batch

      assert_equal(
        [webhook_batch1, webhook_batch2].sort,
        webhook_config.batches.sort
      )
    end
  end

  describe "normalizations" do
    it "normalizes event_types" do
      webhook_config = create_webhook_config(
        event_types: ["\n\t [server_ vote.* \n", "Server.Updated,123", 123, nil, " "]
      )
      assert_equal(["server_vote.*", "server.updated"], webhook_config.event_types)

      webhook_config = create_webhook_config(event_types: ["*"])
      assert_equal(["*"], webhook_config.event_types)
    end

    it "normalizes secret" do
      webhook_config = create_webhook_config(secret: " aaaaaaaa \naaaaaaaa \t\n")

      assert_equal("aaaaaaaaaaaaaaaa", webhook_config.secret)
    end

    it "normalizes method" do
      webhook_config = create_webhook_config(method: " [PO \nst \t\n")

      assert_equal("POST", webhook_config.method)
    end
  end

  describe "validations" do
    it "validates method" do
      webhook_config = build_webhook_config(method: " ")
      webhook_config.validate
      assert(webhook_config.errors.of_kind?(:method, :blank))

      webhook_config = build_webhook_config(method: "DELETE")
      webhook_config.validate
      assert(webhook_config.errors.of_kind?(:method, :inclusion))

      webhook_config = build_webhook_config(method: "POST")
      webhook_config.validate
      assert_not(webhook_config.errors.key?(:method))
    end
  end

  describe ".enabled" do
    it "returns webhook_config with disabled_at nil" do
      _webhook_config1 = create_webhook_config(disabled_at: Time.current)
      webhook_config2 = create_webhook_config(disabled_at: nil)

      assert_equal(
        [webhook_config2],
        described_class.enabled
      )
    end
  end

  describe ".disabled" do
    it "returns webhook_config with disabled_at present" do
      webhook_config1 = create_webhook_config(disabled_at: Time.current)
      _webhook_config2 = create_webhook_config(disabled_at: nil)

      assert_equal(
        [webhook_config1],
        described_class.disabled
      )
    end
  end

  describe ".for" do
    it "returns enabled webhook_config for source and event_type" do
      source = create_server
      other_source = create_server
      webhook_config1 = create_webhook_config(
        source:,
        event_types: ["server_vote.created"],
        disabled_at: nil
      )
      _webhook_config2 = create_webhook_config(
        source: other_source,
        event_types: ["server_vote.created"],
        disabled_at: nil
      )
      _webhook_config3 = create_webhook_config(
        source:,
        event_types: ["server_vote.created"],
        disabled_at: Time.current
      )
      webhook_config4 = create_webhook_config(
        source:,
        event_types: ["test"],
        disabled_at: nil
      )
      webhook_config5 = create_webhook_config(
        source:,
        event_types: ["server_vote.*"],
        disabled_at: nil
      )

      assert_equal(
        [
          webhook_config1,
          webhook_config5
        ].sort,
        described_class.for(source, "server_vote.created").sort
      )

      assert_equal(
        [
          webhook_config1,
          webhook_config4,
          webhook_config5
        ].sort,
        described_class.for(source).sort
      )
    end
  end

  describe "#enabled?" do
    describe "when disabled_at is present" do
      it "returns false" do
        webhook_config = create_webhook_config(disabled_at: Time.current)

        assert_not(webhook_config.enabled?)
      end
    end

    describe "when disabled_at is not present" do
      it "returns true" do
        webhook_config = create_webhook_config(disabled_at: nil)

        assert(webhook_config.enabled?)
      end
    end
  end

  describe "#disabled?" do
    describe "when disabled_at is present" do
      it "returns true" do
        webhook_config = create_webhook_config(disabled_at: Time.current)

        assert(webhook_config.disabled?)
      end
    end

    describe "when disabled_at is not present" do
      it "returns false" do
        webhook_config = create_webhook_config(disabled_at: nil)

        assert_not(webhook_config.disabled?)
      end
    end
  end

  describe "#subscribed? and #not_subscribed?" do
    it "glob matches event_types with given string" do
      [
        [true,  "server_vote.created", ["*"]],
        [true,  "server_vote.created", ["server_vote.created"]],
        [true,  "server_vote.created", ["server*"]],
        [true,  "server_vote.created", ["server_vote.*"]],
        [true,  "server_vote.created", ["*created"]],
        [true,  "server_vote.created", ["aaaa", "server_vote.*"]],
        [false, "server_vote.created", ["server_vote"]]
      ].each do |should_match, str, event_types|
        webhook_config = build_webhook_config(event_types:)

        if should_match
          assert(
            webhook_config.subscribed?(str),
            "Failed for #{should_match.inspect} #{str.inspect} #{event_types.inspect}"
          )
          assert_not(webhook_config.not_subscribed?(str))
        else
          assert_not(
            webhook_config.subscribed?(str),
            "Failed for #{should_match.inspect} #{str.inspect} #{event_types.inspect}"
          )
          assert(webhook_config.not_subscribed?(str))
        end
      end
    end
  end
end
