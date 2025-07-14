# frozen_string_literal: true

require "test_helper"

class Servers::CreateVoteTest < ActiveSupport::TestCase
  let(:described_class) { Servers::CreateVote }

  describe "#call" do
    describe "when server_vote is invalid for some reason" do
      it "returns failure" do
        server = create_server(archived_at: Time.current)
        server_vote = build_server_vote
        account = create_account

        result = nil
        assert_no_difference(-> { ServerVote.count }) do
          result = described_class.new(server, server_vote, "1.1.1.1", account).call
        end

        assert(result.failure?)
        assert(result.errors[:server].any? { it.include?("cannot be archived") })

        assert_no_enqueued_jobs(only: Servers::ConsolidateVoteCountsJob)
        assert_no_enqueued_jobs(only: Webhooks::CreateEvents::ServerVoteCreatedJob)
      end
    end

    describe "when an error is raised" do
      it "raises error" do
        server = create_server
        server_vote = build_server_vote
        account = create_account

        called = 0
        server_vote.stub(:save!, -> { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
          assert_no_difference(-> { ServerVote.count }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(server, server_vote, "1.1.1.1", account).call
            end
          end
        end
        assert_equal(1, called)

        assert_no_enqueued_jobs(only: Servers::ConsolidateVoteCountsJob)
        assert_no_enqueued_jobs(only: Webhooks::CreateEvents::ServerVoteCreatedJob)
      end
    end

    describe "when everything is correct" do
      it "returns success, creates server_vote and enqueues jobs" do
        server = create_server
        server_vote = build_server_vote(reference: "anything123456")
        account = create_account

        result = nil
        assert_difference(-> { ServerVote.count }, 1) do
          result = described_class.new(server, server_vote, "1.1.1.1", account).call
        end

        assert(result.success?)
        assert_equal(ServerVote.last, result.server_vote)
        assert_equal(server, result.server_vote.server)
        assert_equal(server.game, result.server_vote.game)
        assert_equal(server.country_code, result.server_vote.country_code)
        assert_equal("1.1.1.1", result.server_vote.remote_ip)
        assert_equal("anything123456", result.server_vote.reference)
        assert_equal(account, result.server_vote.account)

        assert_enqueued_with(job: Servers::ConsolidateVoteCountsJob, args: [server, "current"], queue: "critical")
        assert_enqueued_with(job: Webhooks::CreateEvents::ServerVoteCreatedJob, args: [result.server_vote])
      end
    end
  end
end
