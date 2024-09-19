# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::IndexQuery do
  describe '#game' do
    it 'returns game' do
      game = create(:game)
      expect(described_class.new.game).to be_nil
      expect(described_class.new(game).game).to eq(game)
    end
  end

  describe '#period' do
    it 'returns period or default' do
      expect(described_class.new.period).to eq(Periods::MONTH)
      expect(described_class.new(nil, 'year').period).to eq('year')
    end
  end

  describe '#country_code' do
    it 'returns country_code or default' do
      expect(described_class.new.country_code).to eq(ServerStat::ALL)
      expect(described_class.new(nil, nil, 'US').country_code).to eq('US')
    end
  end

  describe '#current_time' do
    it 'returns current_time or default' do
      freeze_time do
        expect(described_class.new.current_time).to eq(Time.current)
        expect(described_class.new(nil, nil, nil, 2.days.ago).current_time).to eq(2.days.ago)
      end
    end
  end

  describe '#call' do
    it 'returns accordingly' do
      create_servers_and_votes(
        Time.iso8601('2024-01-07T12:00:00Z'),
        Time.iso8601('2024-01-31T12:00:00Z'),
        Time.iso8601('2024-12-31T12:00:00Z'),
        [
          # Game A, US
          ['Game A', 'Server 1',  'US',  3,  30, 300],
          ['Game A', 'Server 2',  'US', 10, 150, 160],
          ['Game A', 'Server 3',  'US', 75, 100, 175],
          ['Game A', 'Server 4',  'US',  5,   5,  30],
          ['Game A', 'Server 5',  'US',  0,  10,  20],
          ['Game A', 'Server 6',  'US',  0,   0,  10],
          ['Game A', 'Server 7',  'US',  0,   0,   0],
          # Game A, BR
          ['Game A', 'Server 8',  'BR',  1,  20, 200],
          ['Game A', 'Server 9',  'BR', 60, 100, 170],
          ['Game A', 'Server 10', 'BR', 80,  80,  80],

          # Game B, US
          ['Game B', 'Server 11', 'US',  2,  25, 220],
          ['Game B', 'Server 12', 'US', 40, 110, 190],
          ['Game B', 'Server 13', 'US', 50,  50,  50],
        ]
      )

      current_time = Time.iso8601('2024-01-07T12:00:00Z')
      travel_to(current_time) do
        # Game A, US
        expect(query_result('Game A', 'year',  'US', current_time)).to eq([
          ['Server 1', 1,   300],
          ['Server 3', 2,   175],
          ['Server 2', 3,   160],
          ['Server 4', 4,    30],
          ['Server 5', 5,    20],
          ['Server 6', 6,    10],
          ['Server 7', nil, nil],
        ])
        expect(query_result('Game A', 'month',  'US', current_time)).to eq([
          ['Server 2', 1,   150],
          ['Server 3', 2,   100],
          ['Server 1', 3,    30],
          ['Server 5', 4,    10],
          ['Server 4', 5,     5],
          ['Server 7', nil, nil],
          ['Server 6', nil, nil],
        ])
        expect(query_result('Game A', 'week',  'US', current_time)).to eq([
          ['Server 3', 1,    75],
          ['Server 2', 2,    10],
          ['Server 4', 3,     5],
          ['Server 1', 4,     3],
          ['Server 7', nil, nil],
          ['Server 6', nil, nil],
          ['Server 5', nil, nil],
        ])

        # Game A, BR
        expect(query_result('Game A', 'year',  'BR', current_time)).to eq([
          ['Server 8',  1, 200],
          ['Server 9',  2, 170],
          ['Server 10', 3,  80],
        ])
        expect(query_result('Game A', 'month',  'BR', current_time)).to eq([
          ['Server 9',  1, 100],
          ['Server 10', 2,  80],
          ['Server 8',  3,  20],
        ])
        expect(query_result('Game A', 'week',  'BR', current_time)).to eq([
          ['Server 10', 1, 80],
          ['Server 9',  2, 60],
          ['Server 8',  3,  1],
        ])

        # Game A, all
        expect(query_result('Game A', 'year',  'all', current_time)).to eq([
          ['Server 1',  1,   300],
          ['Server 8',  2,   200],
          ['Server 3',  3,   175],
          ['Server 9',  4,   170],
          ['Server 2',  5,   160],
          ['Server 10', 6,    80],
          ['Server 4',  7,    30],
          ['Server 5',  8,    20],
          ['Server 6',  9,    10],
          ['Server 7',  nil, nil],
        ])
        expect(query_result('Game A', 'month',  'all', current_time)).to eq([
          ['Server 2',  1,   150],
          ['Server 9',  2,   100],
          ['Server 3',  3,   100],
          ['Server 10', 4,    80],
          ['Server 1',  5,    30],
          ['Server 8',  6,    20],
          ['Server 5',  7,    10],
          ['Server 4',  8,     5],
          ['Server 7',  nil, nil],
          ['Server 6',  nil, nil],
        ])
        expect(query_result('Game A', 'week',  'all', current_time)).to eq([
          ['Server 10', 1,    80],
          ['Server 3',  2,    75],
          ['Server 9',  3,    60],
          ['Server 2',  4,    10],
          ['Server 4',  5,     5],
          ['Server 1',  6,     3],
          ['Server 8',  7,     1],
          ['Server 7',  nil, nil],
          ['Server 6',  nil, nil],
          ['Server 5',  nil, nil],
        ])

        # Game B, US
        expect(query_result('Game B', 'year', 'US', current_time)).to eq([
          ['Server 11', 1, 220],
          ['Server 12', 2, 190],
          ['Server 13', 3,  50],
        ])
        expect(query_result('Game B', 'month', 'US', current_time)).to eq([
          ['Server 12', 1, 110],
          ['Server 13', 2,  50],
          ['Server 11', 3,  25],
        ])
        expect(query_result('Game B', 'week', 'US', current_time)).to eq([
          ['Server 13', 1, 50],
          ['Server 12', 2, 40],
          ['Server 11', 3,  2],
        ])

        # Game B, all
        expect(query_result('Game B', 'year', 'all', current_time)).to eq([
          ['Server 11', 1, 220],
          ['Server 12', 2, 190],
          ['Server 13', 3,  50],
        ])
        expect(query_result('Game B', 'month', 'all', current_time)).to eq([
          ['Server 12', 1, 110],
          ['Server 13', 2,  50],
          ['Server 11', 3,  25],
        ])
        expect(query_result('Game B', 'week', 'all', current_time)).to eq([
          ['Server 13', 1, 50],
          ['Server 12', 2, 40],
          ['Server 11', 3,  2],
        ])

        # All Games, US
        expect(query_result(nil, 'year', 'US', current_time)).to eq([
          ['Server 1',  1,   300],
          ['Server 11', 1,   220],
          ['Server 12', 2,   190],
          ['Server 3',  2,   175],
          ['Server 2',  3,   160],
          ['Server 13', 3,    50],
          ['Server 4',  4,    30],
          ['Server 5',  5,    20],
          ['Server 6',  6,    10],
          ['Server 7',  nil, nil],
        ])
        expect(query_result(nil, 'month', 'US', current_time)).to eq([
          ['Server 2',  1,   150],
          ['Server 12', 1,   110],
          ['Server 3',  2,   100],
          ['Server 13', 2,    50],
          ['Server 1',  3,    30],
          ['Server 11', 3,    25],
          ['Server 5',  4,    10],
          ['Server 4',  5,     5],
          ['Server 7',  nil, nil],
          ['Server 6',  nil, nil],
        ])
        expect(query_result(nil, 'week', 'US', current_time)).to eq([
          ['Server 3',  1,    75],
          ['Server 13', 1,    50],
          ['Server 12', 2,    40],
          ['Server 2',  2,    10],
          ['Server 4',  3,     5],
          ['Server 11', 3,     2],
          ['Server 1',  4,     3],
          ['Server 7',  nil, nil],
          ['Server 6',  nil, nil],
          ['Server 5',  nil, nil],
        ])

        # All Games, BR
        expect(query_result(nil, 'year',  'BR', current_time)).to eq([
          ['Server 8',  1, 200],
          ['Server 9',  2, 170],
          ['Server 10', 3,  80],
        ])
        expect(query_result(nil, 'month',  'BR', current_time)).to eq([
          ['Server 9',  1, 100],
          ['Server 10', 2,  80],
          ['Server 8',  3,  20],
        ])
        expect(query_result(nil, 'week',  'BR', current_time)).to eq([
          ['Server 10', 1, 80],
          ['Server 9',  2, 60],
          ['Server 8',  3,  1],
        ])

        # All Games, all
        expect(query_result(nil, 'year', 'all', current_time)).to eq([
          ['Server 1',  1,   300],
          ['Server 11', 1,   220],
          ['Server 8',  2,   200],
          ['Server 12', 2,   190],
          ['Server 3',  3,   175],
          ['Server 13', 3,    50],
          ['Server 9',  4,   170],
          ['Server 2',  5,   160],
          ['Server 10', 6,    80],
          ['Server 4',  7,    30],
          ['Server 5',  8,    20],
          ['Server 6',  9,    10],
          ['Server 7',  nil, nil],
        ])
        expect(query_result(nil, 'month', 'all', current_time)).to eq([
          ['Server 2',  1,   150],
          ['Server 12', 1,   110],
          ['Server 9',  2,   100],
          ['Server 13', 2,    50],
          ['Server 3',  3,   100],
          ['Server 11', 3,    25],
          ['Server 10', 4,    80],
          ['Server 1',  5,    30],
          ['Server 8',  6,    20],
          ['Server 5',  7,    10],
          ['Server 4',  8,     5],
          ['Server 7',  nil, nil],
          ['Server 6',  nil, nil],
        ])
        expect(query_result(nil, 'week', 'all', current_time)).to eq([
          ['Server 10', 1,    80],
          ['Server 13', 1,    50],
          ['Server 3',  2,    75],
          ['Server 12', 2,    40],
          ['Server 9',  3,    60],
          ['Server 11', 3,     2],
          ['Server 2',  4,    10],
          ['Server 4',  5,     5],
          ['Server 1',  6,     3],
          ['Server 8',  7,     1],
          ['Server 7',  nil, nil],
          ['Server 6',  nil, nil],
          ['Server 5',  nil, nil],
        ])
      end
    end
  end

  def query_result(game_name, period, country_code, current_time)
    Servers::IndexQuery.new(Game.find_by(name: game_name), period, country_code, current_time).call.map do |server|
      server_stat = ServerStat.find_by(
        server: server,
        game: server.game,
        period: period,
        country_code: country_code,
        reference_date: Periods.reference_date_for(period, current_time)
      )

      [
        server.name,
        server_stat&.ranking_number,
        server_stat&.vote_count,
      ]
    end
  end

  def create_servers_and_votes(week_time, month_time, year_time, rows)
    rows.each do |game_name, server_name, country_code, votes_week, votes_month, votes_year|
      game = Game.find_by(name: game_name)
      game ||= create(:game, name: game_name)

      server = Server.find_by(name: server_name)
      server ||= create(:server, game: game, name: server_name, country_code: country_code)

      votes_week.times do
        create(
          :server_vote,
          server: server,
          game: server.game,
          country_code: server.country_code,
          created_at: week_time
        )
      end
      (votes_month - votes_week).times do
        create(
          :server_vote,
          server: server,
          game: server.game,
          country_code: server.country_code,
          created_at: month_time
        )
      end
      (votes_year - votes_month).times do
        create(
          :server_vote,
          server: server,
          game: server.game,
          country_code: server.country_code,
          created_at: year_time
        )
      end
    end

    Server.find_each do |server|
      Servers::ConsolidateVoteCounts.new(server).process(week_time, year_time)
    end
    Game.find_each do |game|
      Servers::ConsolidateRankings.new(game).process(week_time, year_time)
    end
  end
end
