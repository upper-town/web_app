# frozen_string_literal: true

require "test_helper"

class Servers::ConsolidateVoteCountsSchedulerJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::ConsolidateVoteCountsSchedulerJob }

  describe "#perform" do
    describe "when method is current" do
      it "enqueues ConsolidateVoteCountsJob for each server" do
        server1 = create_server
        server2 = create_server

        described_class.new.perform("current")

        assert_enqueued_with(job: Servers::ConsolidateVoteCountsJob, args: [server1, "current"])
        assert_enqueued_with(job: Servers::ConsolidateVoteCountsJob, args: [server2, "current"])
      end
    end

    describe "when method is all" do
      it "enqueues ConsolidateVoteCountsJob for each server" do
        server1 = create_server
        server2 = create_server

        described_class.new.perform("all")

        assert_enqueued_with(job: Servers::ConsolidateVoteCountsJob, args: [server1, "all"])
        assert_enqueued_with(job: Servers::ConsolidateVoteCountsJob, args: [server2, "all"])
      end
    end

    describe "when method is unknown" do
      it "raises an error" do
        error = assert_raises(StandardError) do
          described_class.new.perform("something_else")
        end

        assert_match(/Invalid method for Servers::ConsolidateVoteCountsSchedulerJob/, error.message)
      end
    end
  end
end
