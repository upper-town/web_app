# frozen_string_literal: true

require "test_helper"

class Servers::CreateVoteTest < ActiveSupport::TestCase
  let(:described_class) { Servers::CreateVote }

  describe "#call" do
    describe "when person has voted for this game recently" do
      it "returns failure" do
        server = create_server
        server_vote = build_server_vote
        request = build_request(remote_ip: "1.1.1.1")
        account = create_account
        rate_limiter_key = "servers_create_vote:#{server.game_id}:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 1)

        result = nil
        assert_no_difference(-> { ServerVote.count }) do
          result = described_class.new(server, server_vote, request, account).call
        end

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/You have already voted for this game\. Please try again .+/) })

        assert_equal(2, Rails.cache.read(rate_limiter_key))

        assert_no_enqueued_jobs(only: Servers::ConsolidateVoteCountsJob)
        assert_no_enqueued_jobs(only: ServerWebhooks::CreateEvents::ServerVoteCreatedJob)
      end
    end

    describe "when server_vote is invalid for some reason" do
      it "returns failure and uncalls rate_limiter" do
        server = create_server(archived_at: Time.current)
        server_vote = build_server_vote
        request = build_request(remote_ip: "1.1.1.1")
        account = create_account
        rate_limiter_key = "servers_create_vote:#{server.game_id}:1.1.1.1"

        result = nil
        assert_no_difference(-> { ServerVote.count }) do
          result = described_class.new(server, server_vote, request, account).call
        end

        assert(result.failure?)
        assert(result.errors[:server].any? { it.match?(/cannot be archived/) })

        assert_equal(0, Rails.cache.read(rate_limiter_key))

        assert_no_enqueued_jobs(only: Servers::ConsolidateVoteCountsJob)
        assert_no_enqueued_jobs(only: ServerWebhooks::CreateEvents::ServerVoteCreatedJob)
      end
    end

    describe "when an error is raised" do
      it "raises error and uncalls rate_limiter" do
        server = create_server
        server_vote = build_server_vote
        request = build_request(remote_ip: "1.1.1.1")
        account = create_account
        rate_limiter_key = "servers_create_vote:#{server.game_id}:1.1.1.1"

        called = 0
        server_vote.stub(:save!, -> { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
          assert_no_difference(-> { ServerVote.count }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(server, server_vote, request, account).call
            end
          end
        end
        assert_equal(1, called)

        assert_equal(0, Rails.cache.read(rate_limiter_key))

        assert_no_enqueued_jobs(only: Servers::ConsolidateVoteCountsJob)
        assert_no_enqueued_jobs(only: ServerWebhooks::CreateEvents::ServerVoteCreatedJob)
      end
    end

    describe "when everything is correct" do
      it "returns success, creates server_vote and enqueues jobs" do
        server = create_server
        server_vote = build_server_vote(reference: "anything123456")
        request = build_request(remote_ip: "1.1.1.1")
        account = create_account
        rate_limiter_key = "servers_create_vote:#{server.game_id}:1.1.1.1"

        result = nil
        assert_difference(-> { ServerVote.count }, 1) do
          result = described_class.new(server, server_vote, request, account).call
        end

        assert(result.success?)
        assert_equal(ServerVote.last, result.server_vote)
        assert_equal(server, result.server_vote.server)
        assert_equal(server.game, result.server_vote.game)
        assert_equal(server.country_code, result.server_vote.country_code)
        assert_equal("1.1.1.1", result.server_vote.remote_ip)
        assert_equal("anything123456", result.server_vote.reference)
        assert_equal(account, result.server_vote.account)

        assert_equal(1, Rails.cache.read(rate_limiter_key))

        assert_enqueued_with(job: Servers::ConsolidateVoteCountsJob, args: [server, "current"], queue: "critical")
        assert_enqueued_with(job: ServerWebhooks::CreateEvents::ServerVoteCreatedJob, args: [result.server_vote])
      end
    end
  end
end
