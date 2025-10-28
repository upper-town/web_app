# frozen_string_literal: true

require "test_helper"

class Webhooks::CreateEventsTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::CreateEvents }

  describe "#call" do
    it "creates events for enabled configs associated with types" do
      server_vote = create_server_vote
      source = server_vote.server

      webhook_config1 = create_webhook_config(source:, event_types: ["*"])
      webhook_config2 = create_webhook_config(source:, event_types: ["server_vote.*"])
      create_webhook_config(source:, event_types: ["*"], disabled_at: Time.current)
      create_webhook_config(source: create_server, event_types: ["*"])

      assert_difference(-> { WebhookEvent.count }, 2) do
        described_class.call(source, "server_vote.created", server_vote)
      end

      webhook_event1 = WebhookEvent.find_by!(config: webhook_config1)
      assert_nil(webhook_event1.batch)
      assert_equal("server_vote.created", webhook_event1.type)
      assert(webhook_event1.uuid.present?)
      assert(webhook_event1.data.present?)

      webhook_event2 = WebhookEvent.find_by!(config: webhook_config2)
      assert_nil(webhook_event2.batch)
      assert_equal("server_vote.created", webhook_event2.type)
      assert(webhook_event2.uuid.present?)
      assert(webhook_event2.data.present?)

      assert_equal(webhook_event1.uuid, webhook_event2.uuid)

      assert_no_difference(-> { WebhookEvent.count }) do
        described_class.call(source, "server_vote.created", server_vote, uuid: webhook_event1.uuid)
      end
    end

    describe "when there isn't any enabled WebhookConfig for type" do
      it "does not create events" do
        server_vote = create_server_vote
        source = server_vote.server

        create_webhook_config(source:, event_types: ["something_else"])
        create_webhook_config(source:, event_types: ["*"], disabled_at: Time.current)
        create_webhook_config(source: create_server, event_types: ["*"])

        assert_difference(-> { WebhookEvent.count }, 0) do
          described_class.call(source, "server_vote.created", server_vote)
        end
      end
    end
  end
end
