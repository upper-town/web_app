# frozen_string_literal: true

require "test_helper"

class ServerWebhookConfigTest < ActiveSupport::TestCase
  let(:described_class) { ServerWebhookConfig }

  describe "associations" do
    it "belongs to server" do
      server_webhook_config = create_server_webhook_config

      assert(server_webhook_config.server.present?)
    end

    it "has many events" do
      server_webhook_config = create_server_webhook_config

      server_webhook_event1 = create_server_webhook_event(config: server_webhook_config)
      server_webhook_event2 = create_server_webhook_event(config: server_webhook_config)
      _server_webhook_event3 = create_server_webhook_event

      assert_equal(
        [server_webhook_event1, server_webhook_event2].sort,
        server_webhook_config.events.sort
      )
    end
  end

  describe "normalizations" do
    it "normalizes event_types" do
      server_webhook_config = create_server_webhook_config(
        event_types: ["\n\t [server_ vote.* \n", "Server.Updated,123", 123, nil, " "]
      )

      assert_equal(["server_vote.*", "server.updated"], server_webhook_config.event_types)
    end

    it "normalizes secret" do
      server_webhook_config = create_server_webhook_config(
        secret: " aaaaaaaa \naaaaaaaa \t\n"
      )

      assert_equal("aaaaaaaaaaaaaaaa", server_webhook_config.secret)
    end

    it "normalizes method" do
      server_webhook_config = create_server_webhook_config(
        method: " [PO \nst \t\n"
      )

      assert_equal("POST", server_webhook_config.method)
    end
  end

  describe "validations" do
    it "validates method" do
      server_webhook_config = build_server_webhook_config(method: " ")
      server_webhook_config.validate
      assert(server_webhook_config.errors.of_kind?(:method, :blank))

      server_webhook_config = build_server_webhook_config(method: "DELETE")
      server_webhook_config.validate
      assert(server_webhook_config.errors.of_kind?(:method, :inclusion))

      server_webhook_config = build_server_webhook_config(method: "POST")
      server_webhook_config.validate
      assert_not(server_webhook_config.errors.key?(:method))
    end
  end

  describe ".enabled" do
    it "returns server_webhook_config with disabled_at nil" do
      _server_webhook_config1 = create_server_webhook_config(disabled_at: Time.current)
      server_webhook_config2 = create_server_webhook_config(disabled_at: nil)

      assert_equal(
        [server_webhook_config2],
        described_class.enabled
      )
    end
  end

  describe ".disabled" do
    it "returns server_webhook_config with disabled_at present" do
      server_webhook_config1 = create_server_webhook_config(disabled_at: Time.current)
      _server_webhook_config2 = create_server_webhook_config(disabled_at: nil)

      assert_equal(
        [server_webhook_config1],
        described_class.disabled
      )
    end
  end

  describe ".for" do
    it "returns enabled server_webhook_config for server and event_type" do
      server = create_server
      other_server = create_server
      server_webhook_config1 = create_server_webhook_config(
        server: server,
        event_types: ["server_vote.created"],
        disabled_at: nil
      )
      _server_webhook_config2 = create_server_webhook_config(
        server: other_server,
        event_types: ["server_vote.created"],
        disabled_at: nil
      )
      _server_webhook_config3 = create_server_webhook_config(
        server: server,
        event_types: ["server_vote.created"],
        disabled_at: Time.current
      )
      _server_webhook_config4 = create_server_webhook_config(
        server: server,
        event_types: ["test.event"],
        disabled_at: nil
      )
      server_webhook_config5 = create_server_webhook_config(
        server: server,
        event_types: ["server_vote.*"],
        disabled_at: nil
      )

      assert_equal(
        [
          server_webhook_config1,
          server_webhook_config5
        ].sort,
        described_class.for(server, "server_vote.created").sort
      )
    end
  end

  describe "#enabled?" do
    describe "when disabled_at is present" do
      it "returns false" do
        server_webhook_config = create_server_webhook_config(disabled_at: Time.current)

        assert_not(server_webhook_config.enabled?)
      end
    end

    describe "when disabled_at is not present" do
      it "returns true" do
        server_webhook_config = create_server_webhook_config(disabled_at: nil)

        assert(server_webhook_config.enabled?)
      end
    end
  end

  describe "#disabled?" do
    describe "when disabled_at is present" do
      it "returns true" do
        server_webhook_config = create_server_webhook_config(disabled_at: Time.current)

        assert(server_webhook_config.disabled?)
      end
    end

    describe "when disabled_at is not present" do
      it "returns false" do
        server_webhook_config = create_server_webhook_config(disabled_at: nil)

        assert_not(server_webhook_config.disabled?)
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
        server_webhook_config = build_server_webhook_config(event_types: event_types)

        if should_match
          assert(
            server_webhook_config.subscribed?(str),
            "Failed for #{should_match.inspect} #{str.inspect} #{event_types.inspect}"
          )
          assert_not(server_webhook_config.not_subscribed?(str))
        else
          assert_not(
            server_webhook_config.subscribed?(str),
            "Failed for #{should_match.inspect} #{str.inspect} #{event_types.inspect}"
          )
          assert(server_webhook_config.not_subscribed?(str))
        end
      end
    end
  end
end
