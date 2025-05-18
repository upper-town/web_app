# frozen_string_literal: true

require "test_helper"

class Servers::ConsolidateRankingsSchedulerJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::ConsolidateRankingsSchedulerJob }

  describe "#perform" do
    describe "when method is current" do
      it "enqueues ConsolidateRankingsJob for each game" do
        game1 = create_game
        game2 = create_game

        described_class.new.perform("current")

        assert_enqueued_with(job: Servers::ConsolidateRankingsJob, args: [game1, "current"])
        assert_enqueued_with(job: Servers::ConsolidateRankingsJob, args: [game2, "current"])
      end
    end

    describe "when method is all" do
      it "enqueues ConsolidateRankingsJob for each game" do
        game1 = create_game
        game2 = create_game

        described_class.new.perform("all")

        assert_enqueued_with(job: Servers::ConsolidateRankingsJob, args: [game1, "all"])
        assert_enqueued_with(job: Servers::ConsolidateRankingsJob, args: [game2, "all"])
      end
    end

    describe "when method is unknown" do
      it "raises an error" do
        error = assert_raises(StandardError) do
          described_class.new.perform("something_else")
        end

        assert_match(/Invalid method for Servers::ConsolidateRankingsSchedulerJob/, error.message)
      end
    end
  end
end
