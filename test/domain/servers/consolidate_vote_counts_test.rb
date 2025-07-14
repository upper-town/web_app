# frozen_string_literal: true

require "test_helper"

class Servers::ConsolidateVoteCountsTest < ActiveSupport::TestCase
  let(:described_class) { Servers::ConsolidateVoteCounts }

  describe "#process_current" do
    it "consolidates vote counts for the current year, month, week" do
      env_with_values("PERIODS_MIN_PAST_TIME" => "2023-01-01T00:00:00Z") do
        current_time = Time.iso8601("2024-09-08T18:00:00Z")
        game1 = create_game
        game2 = create_game
        server = create_server

        create_server_vote(server:, game: game1, country_code: "US", created_at: "2023-12-31T23:59:59Z") # Game1, US, NOT current year, NOT current month, NOT current week
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-01-01T00:00:00Z") # Game1, US, current year,     NOT current month, NOT current week
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-03-01T12:00:00Z") # Game1, US, current year,     NOT current month, NOT current week
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-09-01T23:59:59Z") # Game1, US, current year,     current month,     NOT current week
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-09-02T00:00:00Z") # Game1, US, current year,     current month,     current week
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-09-06T12:00:00Z") # Game1, US, current year,     current month,     current week

        create_server_vote(server:, game: game1, country_code: "BR", created_at: "2024-09-07T12:00:00Z") # Game1, BR, current year, current month, current week
        create_server_vote(server:, game: game1, country_code: "BR", created_at: "2024-09-08T12:00:00Z") # Game1, BR, current year, current month, current week

        create_server_vote(server:, game: game2, country_code: "BR", created_at: "2024-09-08T15:00:00Z") # Game2, BR, current year, current month, current week
        create_server_vote(server:, game: game2, country_code: "BR", created_at: "2024-09-08T18:00:00Z") # Game2, BR, current year, current month, current week

        server_stat_assertions = -> do
          assert_equal(5, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game1, country_code: "BR",  server:).vote_count)
          assert_equal(7, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game1, country_code: "all", server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game2, country_code: "BR",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game2, country_code: "all", server:).vote_count)

          assert_equal(3, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game1, country_code: "BR",  server:).vote_count)
          assert_equal(5, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game1, country_code: "all", server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game2, country_code: "BR",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game2, country_code: "all", server:).vote_count)

          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game1, country_code: "BR",  server:).vote_count)
          assert_equal(4, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game1, country_code: "all", server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game2, country_code: "BR",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game2, country_code: "all", server:).vote_count)
        end

        travel_to(current_time) do
          assert_difference(-> { ServerStat.count }, 15) do
            described_class.new(server).process_current
          end

          assert_equal(15, ServerStat.where(vote_count_consolidated_at: current_time).count)
          server_stat_assertions.call
        end

        travel_to(current_time + 1.hour) do
          assert_no_difference(-> { ServerStat.count }) do
            described_class.new(server).process_current
          end

          assert_equal(15, ServerStat.where(vote_count_consolidated_at: current_time + 1.hour).count)
          server_stat_assertions.call
        end
      end
    end
  end

  describe "#process_all" do
    it "consolidates vote counts for all years, months, weeks" do
      env_with_values("PERIODS_MIN_PAST_TIME" => "2023-01-01T00:00:00Z") do
        current_time = Time.iso8601("2024-09-08T18:00:00Z")
        game1 = create_game
        game2 = create_game
        server = create_server

        create_server_vote(server:, game: game1, country_code: "US", created_at: "2023-12-31T23:59:59Z") # Game1, US, 2023, 2023-12, 2023-12-31
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-01-01T00:00:00Z") # Game1, US, 2024, 2024-01, 2024-01-07
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-03-01T12:00:00Z") # Game1, US, 2024, 2024-03, 2024-03-03
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-09-01T23:59:59Z") # Game1, US, 2024, 2024-09, 2024-09-01
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-09-02T00:00:00Z") # Game1, US, 2024, 2024-09, 2024-09-08
        create_server_vote(server:, game: game1, country_code: "US", created_at: "2024-09-06T12:00:00Z") # Game1, US, 2024, 2024-09, 2024-09-08

        create_server_vote(server:, game: game1, country_code: "BR", created_at: "2024-09-07T12:00:00Z") # Game1, BR, 2024, 2024-09, 2024-09-08
        create_server_vote(server:, game: game1, country_code: "BR", created_at: "2024-09-08T12:00:00Z") # Game1, BR, 2024, 2024-09, 2024-09-08

        create_server_vote(server:, game: game2, country_code: "BR", created_at: "2024-09-08T15:00:00Z") # Game2, BR, 2024, 2024-09, 2024-09-08
        create_server_vote(server:, game: game2, country_code: "BR", created_at: "2024-09-08T18:00:00Z") # Game2, BR, 2024, 2024-09, 2024-09-08

        server_stat_assertions = -> do
          assert_equal(1, ServerStat.find_by!(period: "year", reference_date: "2023-12-31", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "year", reference_date: "2023-12-31", game: game1, country_code: "all", server:).vote_count)
          assert_equal(5, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game1, country_code: "BR",  server:).vote_count)
          assert_equal(7, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game1, country_code: "all", server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game2, country_code: "BR",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game: game2, country_code: "all", server:).vote_count)

          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2023-12-31", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2023-12-31", game: game1, country_code: "all", server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2024-01-31", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2024-01-31", game: game1, country_code: "all", server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2024-03-31", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2024-03-31", game: game1, country_code: "all", server:).vote_count)
          assert_equal(3, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game1, country_code: "BR",  server:).vote_count)
          assert_equal(5, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game1, country_code: "all", server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game2, country_code: "BR",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game: game2, country_code: "all", server:).vote_count)

          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2023-12-31", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2023-12-31", game: game1, country_code: "all", server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-01-07", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-01-07", game: game1, country_code: "all", server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-03-03", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-03-03", game: game1, country_code: "all", server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-09-01", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-09-01", game: game1, country_code: "all", server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game1, country_code: "US",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game1, country_code: "BR",  server:).vote_count)
          assert_equal(4, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game1, country_code: "all", server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game2, country_code: "BR",  server:).vote_count)
          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game: game2, country_code: "all", server:).vote_count)
        end

        travel_to(current_time) do
          assert_difference(-> { ServerStat.count }, 31) do
            described_class.new(server).process_all
          end

          assert_equal(31, ServerStat.where(vote_count_consolidated_at: current_time).count)
          server_stat_assertions.call
        end

        travel_to(current_time + 1.hour) do
          assert_no_difference(-> { ServerStat.count }) do
            described_class.new(server).process_all
          end

          assert_equal(31, ServerStat.where(vote_count_consolidated_at: current_time + 1.hour).count)
          server_stat_assertions.call
        end
      end
    end
  end
end
