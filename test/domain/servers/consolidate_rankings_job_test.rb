# frozen_string_literal: true

require "test_helper"

class Servers::ConsolidateRankingsJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::ConsolidateRankingsJob }

  describe "#perform" do
    describe "when method is current" do
      it "calls process_current" do
        game = create_game

        called = 0
        consolidate_rankings = Servers::ConsolidateRankings.new(game)
        Servers::ConsolidateRankings.stub(:new, ->(arg) { called += 1 ; assert_equal(game, arg) ; consolidate_rankings }) do
          consolidate_rankings.stub(:process_current, -> { called += 1 ; nil }) do
            described_class.new.perform(game, "current")
          end
        end
        assert_equal(2, called)
      end
    end

    describe "when method is all" do
      it "calls process_all" do
        game = create_game

        called = 0
        consolidate_rankings = Servers::ConsolidateRankings.new(game)
        Servers::ConsolidateRankings.stub(:new, ->(arg) { called += 1 ; assert_equal(game, arg) ; consolidate_rankings }) do
          consolidate_rankings.stub(:process_all, -> { called += 1 ; nil }) do
            described_class.new.perform(game, "all")
          end
        end
        assert_equal(2, called)
      end
    end

    describe "when method is unknown" do
      it "raises an error" do
        error = assert_raises(StandardError) do
          described_class.new.perform(create_game.id, "something_else")
        end

        assert_match(/Invalid method for Servers::ConsolidateRankingsJob/, error.message)
      end
    end
  end
end
