# frozen_string_literal: true

require "test_helper"

class Servers::ConsolidateRankingsTest < ActiveSupport::TestCase
  let(:described_class) { Servers::ConsolidateRankings }

  describe "#call when processing current" do
    it "consolidates rankings for the current year, month, week" do
      env_with_values("PERIODS_MIN_PAST_TIME" => "2023-01-01T00:00:00Z") do
        current_time = Time.iso8601("2024-09-08T18:00:00Z")
        game = create_game
        server1 = create_server
        server2 = create_server
        server3 = create_server

        create_server_vote(server: server1, game:, created_at: "2023-12-31T23:59:59Z") # Server1, NOT current year, NOT current month, NOT current week
        create_server_vote(server: server1, game:, created_at: "2024-01-01T00:00:00Z") # Server1, current year,     NOT current month, NOT current week
        create_server_vote(server: server1, game:, created_at: "2024-03-01T12:00:00Z") # Server1, current year,     NOT current month, NOT current week
        create_server_vote(server: server1, game:, created_at: "2024-04-01T12:00:00Z") # Server1, current year,     NOT current month, NOT current week
        create_server_vote(server: server1, game:, created_at: "2024-09-01T23:59:59Z") # Server1, current year,     current month,     NOT current week
        create_server_vote(server: server1, game:, created_at: "2024-09-02T00:00:00Z") # Server1, current year,     current month,     current week
        create_server_vote(server: server1, game:, created_at: "2024-09-06T12:00:00Z") # Server1, current year,     current month,     current week
        create_server_vote(server: server1, game:, created_at: "2024-09-07T12:00:00Z") # Server1, current year,     current month,     current week
        create_server_vote(server: server1, game:, created_at: "2024-09-08T12:00:00Z") # Server1, current year,     current month,     current week

        create_server_vote(server: server2, game:, created_at: "2024-01-01T00:00:00Z") # Server2, current year,     NOT current month, NOT current week
        create_server_vote(server: server2, game:, created_at: "2024-01-02T00:00:00Z") # Server2, current year,     NOT current month, NOT current week
        create_server_vote(server: server2, game:, created_at: "2024-01-03T00:00:00Z") # Server2, current year,     NOT current month, NOT current week
        create_server_vote(server: server2, game:, created_at: "2024-01-04T00:00:00Z") # Server2, current year,     NOT current month, NOT current week

        create_server_vote(server: server3, game:, created_at: "2024-09-01T12:00:00Z") # Server3, current year,     current month,     NOT current week
        create_server_vote(server: server3, game:, created_at: "2024-09-01T13:00:00Z") # Server3, current year,     current month,     NOT current week
        create_server_vote(server: server3, game:, created_at: "2024-09-01T14:00:00Z") # Server3, current year,     current month,     NOT current week
        create_server_vote(server: server3, game:, created_at: "2024-09-01T15:00:00Z") # Server3, current year,     current month,     NOT current week
        create_server_vote(server: server3, game:, created_at: "2024-09-01T23:59:59Z") # Server3, current year,     current month,     NOT current week

        server_stat_assertions = -> do
          assert_equal(1, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game:, server: server1).ranking_number)
          assert_equal(2, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game:, server: server3).ranking_number)
          assert_equal(3, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game:, server: server2).ranking_number)

          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game:, server: server3).ranking_number)
          assert_equal(2, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game:, server: server1).ranking_number)

          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game:, server: server1).ranking_number)
        end

        travel_to(current_time) do
          assert_difference(-> { ServerStat.count }, 6) do
            Servers::ConsolidateVoteCounts.call(server1)
            Servers::ConsolidateVoteCounts.call(server2)
            Servers::ConsolidateVoteCounts.call(server3)
          end

          assert_no_difference(-> { ServerStat.count }) do
            described_class.call(game)
          end

          assert_equal(6, ServerStat.where(ranking_number_consolidated_at: current_time).count)
          server_stat_assertions.call
        end

        travel_to(current_time + 1.hour) do
          assert_no_difference(-> { ServerStat.count }) do
            Servers::ConsolidateVoteCounts.call(server1)
            Servers::ConsolidateVoteCounts.call(server2)
            Servers::ConsolidateVoteCounts.call(server3)
          end

          assert_no_difference(-> { ServerStat.count }) do
            described_class.call(game)
          end

          assert_equal(6, ServerStat.where(ranking_number_consolidated_at: current_time + 1.hour).count)
          server_stat_assertions.call
        end
      end
    end
  end

  describe "#call when processing all" do
    it "consolidates rankings for all years, months, weeks" do
      env_with_values("PERIODS_MIN_PAST_TIME" => "2023-01-01T00:00:00Z") do
        current_time = Time.iso8601("2024-09-08T18:00:00Z")
        game = create_game
        server1 = create_server
        server2 = create_server
        server3 = create_server

        create_server_vote(server: server1, game:, created_at: "2023-12-31T23:59:59Z") # Server1, 2023, 2023-12, 2023-12-31
        create_server_vote(server: server1, game:, created_at: "2024-01-01T00:00:00Z") # Server1, 2024, 2024-01, 2024-01-07
        create_server_vote(server: server1, game:, created_at: "2024-03-01T12:00:00Z") # Server1, 2024, 2024-03, 2024-03-03
        create_server_vote(server: server1, game:, created_at: "2024-04-01T12:00:00Z") # Server1, 2024, 2024-04, 2024-04-07
        create_server_vote(server: server1, game:, created_at: "2024-09-01T23:59:59Z") # Server1, 2024, 2024-09, 2024-09-01
        create_server_vote(server: server1, game:, created_at: "2024-09-02T00:00:00Z") # Server1, 2024, 2024-09, 2024-09-08
        create_server_vote(server: server1, game:, created_at: "2024-09-06T12:00:00Z") # Server1, 2024, 2024-09, 2024-09-08
        create_server_vote(server: server1, game:, created_at: "2024-09-07T12:00:00Z") # Server1, 2024, 2024-09, 2024-09-08
        create_server_vote(server: server1, game:, created_at: "2024-09-08T12:00:00Z") # Server1, 2024, 2024-09, 2024-09-08

        create_server_vote(server: server2, game:, created_at: "2024-01-01T00:00:00Z") # Server2, 2024, 2024-01, 2024-01-07
        create_server_vote(server: server2, game:, created_at: "2024-01-02T00:00:00Z") # Server2, 2024, 2024-01, 2024-01-07
        create_server_vote(server: server2, game:, created_at: "2024-01-03T00:00:00Z") # Server2, 2024, 2024-01, 2024-01-07
        create_server_vote(server: server2, game:, created_at: "2024-01-04T00:00:00Z") # Server2, 2024, 2024-01, 2024-01-07

        create_server_vote(server: server3, game:, created_at: "2024-09-01T12:00:00Z") # Server3, 2024, 2024-09, 2024-09-01
        create_server_vote(server: server3, game:, created_at: "2024-09-01T13:00:00Z") # Server3, 2024, 2024-09, 2024-09-01
        create_server_vote(server: server3, game:, created_at: "2024-09-01T14:00:00Z") # Server3, 2024, 2024-09, 2024-09-01
        create_server_vote(server: server3, game:, created_at: "2024-09-01T15:00:00Z") # Server3, 2024, 2024-09, 2024-09-01
        create_server_vote(server: server3, game:, created_at: "2024-09-01T23:59:59Z") # Server3, 2024, 2024-09, 2024-09-01

        server_stat_assertions = -> do
          assert_equal(1, ServerStat.find_by!(period: "year", reference_date: "2023-12-31", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game:, server: server1).ranking_number)
          assert_equal(2, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game:, server: server3).ranking_number)
          assert_equal(3, ServerStat.find_by!(period: "year", reference_date: "2024-12-31", game:, server: server2).ranking_number)

          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2023-12-31", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2024-01-31", game:, server: server2).ranking_number)
          assert_equal(2, ServerStat.find_by!(period: "month", reference_date: "2024-01-31", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2024-03-31", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2024-04-30", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game:, server: server3).ranking_number)
          assert_equal(2, ServerStat.find_by!(period: "month", reference_date: "2024-09-30", game:, server: server1).ranking_number)

          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2023-12-31", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-01-07", game:, server: server2).ranking_number)
          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-01-07", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-03-03", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-04-07", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-09-01", game:, server: server3).ranking_number)
          assert_equal(2, ServerStat.find_by!(period: "week", reference_date: "2024-09-01", game:, server: server1).ranking_number)
          assert_equal(1, ServerStat.find_by!(period: "week", reference_date: "2024-09-08", game:, server: server1).ranking_number)
        end

        travel_to(current_time) do
          assert_difference(-> { ServerStat.count }, 19) do
            Servers::ConsolidateVoteCounts.call(server1, nil, Periods.min_past_time, current_time)
            Servers::ConsolidateVoteCounts.call(server2, nil, Periods.min_past_time, current_time)
            Servers::ConsolidateVoteCounts.call(server3, nil, Periods.min_past_time, current_time)
          end

          assert_no_difference(-> { ServerStat.count }) do
            described_class.call(game, nil, Periods.min_past_time, current_time)
          end

          assert_equal(19, ServerStat.where(ranking_number_consolidated_at: current_time).count)
          server_stat_assertions.call
        end

        travel_to(current_time + 1.hour) do
          assert_no_difference(-> { ServerStat.count }) do
            Servers::ConsolidateVoteCounts.call(server1, nil, Periods.min_past_time, current_time)
            Servers::ConsolidateVoteCounts.call(server2, nil, Periods.min_past_time, current_time)
            Servers::ConsolidateVoteCounts.call(server3, nil, Periods.min_past_time, current_time)
          end

          assert_no_difference(-> { ServerStat.count }) do
            described_class.call(game, nil, Periods.min_past_time, current_time)
          end

          assert_equal(19, ServerStat.where(ranking_number_consolidated_at: current_time + 1.hour).count)
          server_stat_assertions.call
        end
      end
    end
  end
end
