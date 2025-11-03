# frozen_string_literal: true

require "test_helper"

class Servers::CreateVoteTest < ActiveSupport::TestCase
  let(:described_class) { Servers::CreateVote }

  describe "#call" do
    describe "when server_vote is already persisted" do
      it "returns failure and does not create server_vote nor webhook events" do
        server = create_server
        server_vote = create_server_vote
        account = create_account

        webhooks_create_events_called = 0
        Webhooks::CreateEvents.stub(:call, ->(*) { webhooks_create_events_called += 1 ; nil }) do
          result = nil
          assert_no_difference(-> { ServerVote.count }) do
            result = described_class.new(server, server_vote, "1.1.1.1", account).call
          end

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :invalid))
          assert_equal(server_vote, result.server_vote)
        end
        assert_equal(0, webhooks_create_events_called)
      end
    end

    describe "when server_vote is invalid for some reason" do
      it "returns failure and does not create server_vote nor webhook events" do
        server = create_server(archived_at: Time.current)
        server_vote = build_server_vote
        account = create_account

        webhooks_create_events_called = 0
        Webhooks::CreateEvents.stub(:call, ->(*) { webhooks_create_events_called += 1 ; nil }) do
          result = nil
          assert_no_difference(-> { ServerVote.count }) do
            result = described_class.new(server, server_vote, "1.1.1.1", account).call
          end

          assert(result.failure?)
          assert(result.errors[:server].any? { it.include?("cannot be archived") })
          assert_equal(server_vote, result.server_vote)
        end
        assert_equal(0, webhooks_create_events_called)
      end
    end

    describe "when an error is raised" do
      it "raises error" do
        server = create_server
        server_vote = build_server_vote
        account = create_account

        server_vote_save_called = 0
        webhooks_create_events_called = 0
        Webhooks::CreateEvents.stub(:call, ->(*) { webhooks_create_events_called += 1 ; nil }) do
          server_vote.stub(:save!, -> { server_vote_save_called += 1 ; raise ActiveRecord::ActiveRecordError }) do
            assert_no_difference(-> { ServerVote.count }) do
              assert_raises(ActiveRecord::ActiveRecordError) do
                described_class.new(server, server_vote, "1.1.1.1", account).call
              end
            end
          end
        end
        assert_equal(1, server_vote_save_called)
        assert_equal(0, webhooks_create_events_called)
      end
    end

    describe "when everything is correct" do
      it "returns success, creates server_vote and webhook events" do
        server = create_server
        server_vote = build_server_vote(reference: "anything123456")
        account = create_account

        webhooks_create_events_called = 0
        Webhooks::CreateEvents.stub(:call, ->(*webhooks_create_events_args) do
          webhooks_create_events_called += 1
          assert_equal(
            [server, "server_vote.created", server_vote],
            webhooks_create_events_args
          )
          nil
        end) do
          result = nil
          assert_difference(-> { ServerVote.count }, 1) do
            result = described_class.new(server, server_vote, "1.1.1.1", account).call
          end

          assert(result.success?)
          assert_equal(ServerVote.last, result.server_vote)
          assert_equal(server, result.server_vote.server)
          assert_equal(server.game, result.server_vote.game)
          assert_equal("1.1.1.1", result.server_vote.remote_ip)
          assert_equal("anything123456", result.server_vote.reference)
          assert_equal(account, result.server_vote.account)
        end
        assert_equal(1, webhooks_create_events_called)
      end
    end
  end
end
