# frozen_string_literal: true

require "test_helper"

class Webhooks::CreateEvents::ServerVoteCreatedJobTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::CreateEvents::ServerVoteCreatedJob }

  describe "#perform" do
    describe "when server does not have enabled configs that subscribe to the event_type" do
      it "does not create WebhookEvent records and does not publish" do
        server = create_server(country_code: "US")
        _webhook_config1 = create_webhook_config(source: server, event_types: ["server_vote.created"], disabled_at: Time.current)
        _webhook_config2 = create_webhook_config(source: server, event_types: ["test.event"], disabled_at: nil)
        account = create_account
        server_vote = create_server_vote(
          game: server.game,
          server:,
          country_code: server.country_code,
          reference: "anything123456",
          remote_ip: "1.1.1.1",
          account:,
          created_at: Time.iso8601("2024-09-02T12:00:01Z")
        )

        assert_difference(-> { WebhookEvent.count }, 0) do
          described_class.new.perform(server_vote)
        end

        assert_no_enqueued_jobs(only: Webhooks::PublishEventJob)
      end
    end

    describe "when server has enabled configs that subscribe to the event_type" do
      it "creates WebhookEvent for them and publishes events" do
        server = create_server(country_code: "US")
        webhook_config1  = create_webhook_config(source: server, event_types: ["server_vote.created"], disabled_at: nil)
        webhook_config2  = create_webhook_config(source: server, event_types: ["server_vote.*"], disabled_at: nil)
        _webhook_config3 = create_webhook_config(source: server, event_types: ["test.event"], disabled_at: nil)
        account = create_account
        server_vote = create_server_vote(
          game: server.game,
          server:,
          country_code: server.country_code,
          reference: "anything123456",
          remote_ip: "1.1.1.1",
          account:,
          created_at: Time.iso8601("2024-09-02T12:00:01Z")
        )

        assert_difference(-> { WebhookEvent.count }, 2) do
          described_class.new.perform(server_vote)
        end

        webhook_event1 = WebhookEvent.find_by!(config: webhook_config1)
        webhook_event2 = WebhookEvent.find_by!(config: webhook_config2)
        expected_data = {
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
        assert_equal("server_vote.created", webhook_event1.type)
        assert_equal(expected_data, webhook_event1.data)
        assert_equal("pending", webhook_event1.status)

        assert_equal("server_vote.created", webhook_event2.type)
        assert_equal(expected_data, webhook_event2.data)
        assert_equal("pending", webhook_event2.status)

        assert_enqueued_with(job: Webhooks::PublishEventJob, args: [webhook_event1])
        assert_enqueued_with(job: Webhooks::PublishEventJob, args: [webhook_event2])
      end

      describe "when an error is raised during creation of WebhookEvent" do
        it "raises the error and rolls back" do
          server = create_server(country_code: "US")
          _webhook_config1 = create_webhook_config(source: server, event_types: ["server_vote.created"], disabled_at: nil)
          _webhook_config2 = create_webhook_config(source: server, event_types: ["server_vote.*"], disabled_at: nil)
          _webhook_config3 = create_webhook_config(source: server, event_types: ["test.event"], disabled_at: nil)
          account = create_account
          server_vote = create_server_vote(
            game: server.game,
            server:,
            country_code: server.country_code,
            reference: "anything123456",
            remote_ip: "1.1.1.1",
            account:,
            created_at: Time.iso8601("2024-09-02T12:00:01Z")
          )

          called = 0
          WebhookEvent.stub(:create!, ->(*) do
            called += 1
            raise ActiveRecord::ActiveRecordError
          end) do
            assert_difference(-> { WebhookEvent.count }, 0) do
              assert_raises(ActiveRecord::ActiveRecordError) do
                described_class.new.perform(server_vote)
              end
            end
          end
          assert_equal(1, called)

          assert_no_enqueued_jobs(only: Webhooks::PublishEventJob)
        end
      end
    end
  end
end
