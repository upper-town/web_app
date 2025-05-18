# frozen_string_literal: true

require "test_helper"

class ServerWebhooks::CreateEvents::ServerVoteCreatedJobTest < ActiveSupport::TestCase
  let(:described_class) { ServerWebhooks::CreateEvents::ServerVoteCreatedJob }

  describe "#perform" do
    describe "when server does not have enabled configs that subscribe to the event_type" do
      it "does not create ServerWebhookEvent records and does not publish" do
        server = create_server(country_code: "US")
        _server_webhook_config1 = create_server_webhook_config(server: server, event_types: ["server_vote.created"], disabled_at: Time.current)
        _server_webhook_config2 = create_server_webhook_config(server: server, event_types: ["test.event"], disabled_at: nil)
        account = create_account
        server_vote = create_server_vote(
          game: server.game,
          server: server,
          country_code: server.country_code,
          reference: "anything123456",
          remote_ip: "1.1.1.1",
          account: account,
          created_at: Time.iso8601("2024-09-02T12:00:01Z")
        )

        assert_difference(-> { ServerWebhookEvent.count }, 0) do
          described_class.new.perform(server_vote)
        end

        assert_no_enqueued_jobs(only: ServerWebhooks::PublishEventJob)
      end
    end

    describe "when server has enabled configs that subscribe to the event_type" do
      it "creates ServerWebhookEvent for them and publishes events" do
        server = create_server(country_code: "US")
        server_webhook_config1 = create_server_webhook_config(server: server, event_types: ["server_vote.created"], disabled_at: nil)
        server_webhook_config2 = create_server_webhook_config(server: server, event_types: ["server_vote.*"], disabled_at: nil)
        _server_webhook_config3 = create_server_webhook_config(server: server, event_types: ["test.event"], disabled_at: nil)
        account = create_account
        server_vote = create_server_vote(
          game: server.game,
          server: server,
          country_code: server.country_code,
          reference: "anything123456",
          remote_ip: "1.1.1.1",
          account: account,
          created_at: Time.iso8601("2024-09-02T12:00:01Z")
        )

        assert_difference(-> { ServerWebhookEvent.count }, 2) do
          described_class.new.perform(server_vote)
        end

        server_webhook_event1 = ServerWebhookEvent.find_by!(config: server_webhook_config1)
        server_webhook_event2 = ServerWebhookEvent.find_by!(config: server_webhook_config2)
        expected_payload = {
          "server_vote" => {
            "uuid"         => server_vote.uuid,
            "game_id"      => server.game_id,
            "server_id"    => server.id,
            "country_code" => "US",
            "reference"    => "anything123456",
            "remote_ip"    => "1.1.1.1",
            "account_uuid" => account.uuid,
            "created_at"   => "2024-09-02T12:00:01Z"
          }
        }
        assert_equal("server_vote.created", server_webhook_event1.type)
        assert_equal(expected_payload, server_webhook_event1.payload)
        assert_equal("pending", server_webhook_event1.status)
        assert_equal(server_vote.server_id, server_webhook_event1.server_id)

        assert_equal("server_vote.created", server_webhook_event2.type)
        assert_equal(expected_payload, server_webhook_event2.payload)
        assert_equal("pending", server_webhook_event2.status)
        assert_equal(server_vote.server_id, server_webhook_event2.server_id)

        assert_enqueued_with(job: ServerWebhooks::PublishEventJob, args: [server_webhook_event1])
        assert_enqueued_with(job: ServerWebhooks::PublishEventJob, args: [server_webhook_event2])
      end

      describe "when an error is raised during creation of ServerWebhookEvent" do
        it "raises the error and rolls back" do
          server = create_server(country_code: "US")
          _server_webhook_config1 = create_server_webhook_config(server: server, event_types: ["server_vote.created"], disabled_at: nil)
          _server_webhook_config2 = create_server_webhook_config(server: server, event_types: ["server_vote.*"], disabled_at: nil)
          _server_webhook_config3 = create_server_webhook_config(server: server, event_types: ["test.event"], disabled_at: nil)
          account = create_account
          server_vote = create_server_vote(
            game: server.game,
            server: server,
            country_code: server.country_code,
            reference: "anything123456",
            remote_ip: "1.1.1.1",
            account: account,
            created_at: Time.iso8601("2024-09-02T12:00:01Z")
          )

          called = 0
          ServerWebhookEvent.stub(:create!, ->(*) do
            called += 1
            raise ActiveRecord::ActiveRecordError
          end) do
            assert_difference(-> { ServerWebhookEvent.count }, 0) do
              assert_raises(ActiveRecord::ActiveRecordError) do
                described_class.new.perform(server_vote)
              end
            end
          end
          assert_equal(1, called)

          assert_no_enqueued_jobs(only: ServerWebhooks::PublishEventJob)
        end
      end
    end
  end
end
