# frozen_string_literal: true

require "test_helper"

class Servers::ConsolidateVoteCountsJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::ConsolidateVoteCountsJob }

  describe "#perform" do
    describe "when method is current" do
      it "calls process_current" do
        server = create_server
        consolidate_vote_counts = Servers::ConsolidateVoteCounts.new(server)

        called = 0
        Servers::ConsolidateVoteCounts.stub(:new, ->(arg) do
          called += 1
          assert_equal(server, arg)
          consolidate_vote_counts
        end) do
          consolidate_vote_counts.stub(:process_current, -> { called += 1 ; nil }) do
            described_class.new.perform(server, "current")
          end
        end
        assert_equal(2, called)
      end
    end

    describe "when method is all" do
      it "calls process_all" do
        server = create_server
        consolidate_vote_counts = Servers::ConsolidateVoteCounts.new(server)

        called = 0
        Servers::ConsolidateVoteCounts.stub(:new, ->(arg) do
          called += 1
          assert_equal(arg, server)
          consolidate_vote_counts
        end) do
          consolidate_vote_counts.stub(:process_all, -> { called += 1 ; nil }) do
            described_class.new.perform(server, "all")
          end
        end
        assert_equal(2, called)
      end
    end

    describe "when method is unknown" do
      it "raises an error" do
        error = assert_raises(StandardError) do
          described_class.new.perform(create_server.id, "something_else")
        end

        assert_match(/Invalid method for Servers::ConsolidateVoteCountsJob/, error.message)
      end
    end
  end
end
