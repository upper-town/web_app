# frozen_string_literal: true

require "test_helper"

class Servers::StatsConsolidatorTest < ActiveSupport::TestCase
  let(:described_class) { Servers::StatsConsolidator }

  describe "#call" do
    it "consolidates only for servers and games pending or missing consolidation for the current month or year" do
      current_time = Time.iso8601("2025-06-10T18:00:00Z")

      travel_to(current_time) do
        game1 = create_game
        game2 = create_game
        server1 = create_server(game: game1)
        server2 = create_server
        server3 = create_server(game: game1)
        server4 = create_server
        server5 = create_server
        server6 = create_server
        server7 = create_server(game: game2)
        server8 = create_server
        server9 = create_server
        _server10 = create_server

        create_server_vote(server: server1, created_at:      "2025-06-01T12:00:01Z")
        create_server_vote(server: server1, created_at:      "2025-06-01T12:00:00Z")
        create_server_stat(server: server1, vote_count_consolidated_at: "2025-06-01T11:59:59Z", reference_date: "2025-12-31")

        create_server_vote(server: server2, created_at:      "2025-06-01T12:00:00Z")
        create_server_stat(server: server2, vote_count_consolidated_at: "2025-06-01T12:00:01Z", reference_date: "2025-12-31") # already consolidated

        create_server_vote(server: server3, created_at:      "2025-06-01T12:00:00Z")

        create_server_vote(server: server4, created_at:      "2025-05-01T12:00:01Z")
        create_server_stat(server: server4, vote_count_consolidated_at: "2025-05-01T11:59:59Z", reference_date: "2025-05-31") # previous month

        create_server_vote(server: server5, created_at:      "2024-06-01T12:00:01Z")
        create_server_stat(server: server5, vote_count_consolidated_at: "2024-06-01T11:59:59Z", reference_date: "2024-12-31") # previous year

        create_server_vote(server: server6, created_at:      "2026-06-01T12:00:01Z")
        create_server_stat(server: server6, vote_count_consolidated_at: "2026-06-01T11:59:59Z", reference_date: "2026-12-31") # next year

        create_server_vote(server: server7, created_at:      "2025-06-01T12:00:00Z")
        create_server_stat(server: server7, vote_count_consolidated_at: "2025-06-01T11:59:59Z", reference_date: "2025-06-30")

        create_server_vote(server: server8, created_at:      "2025-06-01T12:00:00Z")
        create_server_stat(server: server8, vote_count_consolidated_at: "2025-06-01T11:59:59Z", reference_date: "2025-06-16") # next week

        create_server_vote(server: server9, created_at:      "2025-06-10T18:00:01Z") # future vote
        create_server_stat(server: server9, vote_count_consolidated_at: "2025-06-01T11:59:59Z", reference_date: "2025-12-31")

        servers_consolidate_rankings_called = 0
        servers_consolidate_vote_counts_called = 0
        Servers::ConsolidateVoteCounts.stub(:call, ->(server, periods, time) do
          assert_includes([server1, server3, server7], server)
          assert_equal(["year", "month", "week"], periods)
          assert_equal(current_time, time)
          servers_consolidate_vote_counts_called += 1
          nil
        end) do
          Servers::ConsolidateRankings.stub(:call, ->(game, periods, time) do
            assert_includes([game1, game2], game)
            assert_equal(["year", "month", "week"], periods)
            assert_equal(current_time, time)
            servers_consolidate_rankings_called += 1
            nil
          end) do
            described_class.call
          end
        end
        assert_equal(3, servers_consolidate_vote_counts_called)
        assert_equal(2, servers_consolidate_rankings_called)
      end
    end
  end
end
