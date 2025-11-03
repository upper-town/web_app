# frozen_string_literal: true

require "test_helper"

class Servers::IndexStatsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Servers::IndexStatsQuery }

  describe "#server_ids" do
    it "returns server_ids" do
      assert_equal([1, 2, 3], described_class.new([1, 2, 3]).server_ids)
    end
  end

  describe "#current_time" do
    it "returns current_time or default" do
      freeze_time do
        assert_equal(Time.current, described_class.new([]).current_time)
        assert_equal(2.days.ago, described_class.new([], 2.days.ago).current_time)
      end
    end
  end

  describe "#call" do
    it "returns accordingly" do
      create_servers_and_votes(
        Time.iso8601("2024-01-07T12:00:00Z"),
        Time.iso8601("2024-01-31T12:00:00Z"),
        Time.iso8601("2024-12-31T12:00:00Z"),
        [
          # Game A, US
          ["Game A", "Server 1",  "US",  3,  30, 300],
          ["Game A", "Server 2",  "US", 10, 150, 160],
          ["Game A", "Server 3",  "US", 75, 100, 175],
          ["Game A", "Server 4",  "US",  5,   5,  30],
          ["Game A", "Server 5",  "US",  0,  10,  20],
          ["Game A", "Server 6",  "US",  0,   0,  10],
          ["Game A", "Server 7",  "US",  0,   0,   0],
          # Game A, BR
          ["Game A", "Server 8",  "BR",  1,  20, 200],
          ["Game A", "Server 9",  "BR", 60, 100, 170],
          ["Game A", "Server 10", "BR", 80,  80,  80],

          # Game B, US
          ["Game B", "Server 11", "US",  2,  25, 220],
          ["Game B", "Server 12", "US", 40, 110, 190],
          ["Game B", "Server 13", "US", 50,  50,  50]
        ]
      )

      current_time = Time.iso8601("2024-01-07T12:00:00Z")
      travel_to(current_time) do
        assert_equal(
          {
            Server.find_by!(name: "Server 1").id => {
              "year"  => { ranking_number: 1, vote_count: 300 },
              "month" => { ranking_number: 5, vote_count:  30 },
              "week"  => { ranking_number: 6, vote_count:   3 }
            },
            Server.find_by!(name: "Server 2").id => {
              "year"  => { ranking_number: 5, vote_count: 160 },
              "month" => { ranking_number: 1, vote_count: 150 },
              "week"  => { ranking_number: 4, vote_count:  10 }
            },
            Server.find_by!(name: "Server 3").id => {
              "year"  => { ranking_number: 3, vote_count: 175 },
              "month" => { ranking_number: 3, vote_count: 100 },
              "week"  => { ranking_number: 2, vote_count:  75 }
            },
            Server.find_by!(name: "Server 4").id => {
              "year"  => { ranking_number: 7, vote_count: 30 },
              "month" => { ranking_number: 8, vote_count:  5 },
              "week"  => { ranking_number: 5, vote_count:  5 }
            },
            Server.find_by!(name: "Server 5").id => {
              "year"  => { ranking_number: 8, vote_count: 20 },
              "month" => { ranking_number: 7, vote_count: 10 }
            },
            Server.find_by!(name: "Server 6").id => {
              "year"  => { ranking_number: 9, vote_count: 10 }
            },
            # Server.find_by!(name: 'Server 7').id => {},
            Server.find_by!(name: "Server 8").id => {
              "year"  => { ranking_number: 2, vote_count: 200 },
              "month" => { ranking_number: 6, vote_count:  20 },
              "week"  => { ranking_number: 7, vote_count:   1 }
            },
            Server.find_by!(name: "Server 9").id => {
              "year"  => { ranking_number: 4, vote_count: 170 },
              "month" => { ranking_number: 2, vote_count: 100 },
              "week"  => { ranking_number: 3, vote_count:  60 }
            },
            Server.find_by!(name: "Server 10").id => {
              "year"  => { ranking_number: 6, vote_count: 80 },
              "month" => { ranking_number: 4, vote_count: 80 },
              "week"  => { ranking_number: 1, vote_count: 80 }
            },
            Server.find_by!(name: "Server 11").id => {
              "year"  => { ranking_number: 1, vote_count: 220 },
              "month" => { ranking_number: 3, vote_count:  25 },
              "week"  => { ranking_number: 3, vote_count:   2 }
            },
            Server.find_by!(name: "Server 12").id => {
              "year"  => { ranking_number: 2, vote_count: 190 },
              "month" => { ranking_number: 1, vote_count: 110 },
              "week"  => { ranking_number: 2, vote_count:  40 }
            },
            Server.find_by!(name: "Server 13").id => {
              "year"  => { ranking_number: 3, vote_count: 50 },
              "month" => { ranking_number: 2, vote_count: 50 },
              "week"  => { ranking_number: 1, vote_count: 50 }
            }
          },
          query_result(Server.pluck(:id), current_time)
        )
      end
    end
  end

  def query_result(server_ids, current_time)
    Servers::IndexStatsQuery.new(server_ids, current_time).call
  end

  def create_servers_and_votes(week_time, month_time, year_time, rows)
    rows.each do |game_name, server_name, country_code, votes_week, votes_month, votes_year|
      game = Game.find_by(name: game_name)
      game ||= create_game(name: game_name)

      server = Server.find_by(name: server_name)
      server ||= create_server(game:, name: server_name, country_code:)

      votes_week.times do
        create_server_vote(
          server:,
          game: server.game,
          created_at: week_time
        )
      end
      (votes_month - votes_week).times do
        create_server_vote(
          server:,
          game: server.game,
          created_at: month_time
        )
      end
      (votes_year - votes_month).times do
        create_server_vote(
          server:,
          game: server.game,
          created_at: year_time
        )
      end
    end

    Server.find_each do |server|
      Servers::ConsolidateVoteCounts.call(server, nil, week_time, year_time)
    end
    Game.find_each do |game|
      Servers::ConsolidateRankings.call(game, nil, week_time, year_time)
    end
  end
end
