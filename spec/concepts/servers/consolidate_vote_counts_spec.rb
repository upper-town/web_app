# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::ConsolidateVoteCounts do
  around do |example|
    EnvVarHelper.with_values('PERIODS_MIN_PAST_TIME' => '2023-01-01T00:00:00Z') do
      example.run
    end
  end

  describe '#process_current' do
    it 'consolidates vote counts for the current year, month, week' do
      current_time = Time.iso8601('2024-09-08T18:00:00Z')
      game1 = create(:game)
      game2 = create(:game)
      server = create(:server)

      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2023-12-31T23:59:59Z') # Game1, US, NOT current year, NOT current month, NOT current week
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-01-01T00:00:00Z') # Game1, US, current year,     NOT current month, NOT current week
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-03-01T12:00:00Z') # Game1, US, current year,     NOT current month, NOT current week
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-09-01T23:59:59Z') # Game1, US, current year,     current month,     NOT current week
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-09-02T00:00:00Z') # Game1, US, current year,     current month,     current week
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-09-06T12:00:00Z') # Game1, US, current year,     current month,     current week

      create(:server_vote, server: server, game: game1, country_code: 'BR', created_at: '2024-09-07T12:00:00Z') # Game1, BR, current year, current month, current week
      create(:server_vote, server: server, game: game1, country_code: 'BR', created_at: '2024-09-08T12:00:00Z') # Game1, BR, current year, current month, current week

      create(:server_vote, server: server, game: game2, country_code: 'BR', created_at: '2024-09-08T15:00:00Z') # Game2, BR, current year, current month, current week
      create(:server_vote, server: server, game: game2, country_code: 'BR', created_at: '2024-09-08T18:00:00Z') # Game2, BR, current year, current month, current week

      server_stat_assertions = proc do
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game1, country_code: 'US',  server: server).vote_count).to eq(5)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game1, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game1, country_code: 'all', server: server).vote_count).to eq(7)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game2, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game2, country_code: 'all', server: server).vote_count).to eq(2)

        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game1, country_code: 'US',  server: server).vote_count).to eq(3)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game1, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game1, country_code: 'all', server: server).vote_count).to eq(5)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game2, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game2, country_code: 'all', server: server).vote_count).to eq(2)

        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game1, country_code: 'US',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game1, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game1, country_code: 'all', server: server).vote_count).to eq(4)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game2, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game2, country_code: 'all', server: server).vote_count).to eq(2)
      end

      travel_to(current_time) do
        expect do
          described_class.new(server).process_current
        end.to change(ServerStat, :count).by(15)

        expect(ServerStat.where(vote_count_consolidated_at: current_time).count).to eq(15)
        server_stat_assertions.call
      end

      travel_to(current_time + 1.hour) do
        expect do
          described_class.new(server).process_current
        end.not_to change(ServerStat, :count)

        expect(ServerStat.where(vote_count_consolidated_at: current_time + 1.hour).count).to eq(15)
        server_stat_assertions.call
      end
    end
  end

  describe '#process_all' do
    it 'consolidates vote counts for all years, months, weeks' do
      current_time = Time.iso8601('2024-09-08T18:00:00Z')
      game1 = create(:game)
      game2 = create(:game)
      server = create(:server)

      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2023-12-31T23:59:59Z') # Game1, US, 2023, 2023-12, 2023-12-31
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-01-01T00:00:00Z') # Game1, US, 2024, 2024-01, 2024-01-07
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-03-01T12:00:00Z') # Game1, US, 2024, 2024-03, 2024-03-03
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-09-01T23:59:59Z') # Game1, US, 2024, 2024-09, 2024-09-01
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-09-02T00:00:00Z') # Game1, US, 2024, 2024-09, 2024-09-08
      create(:server_vote, server: server, game: game1, country_code: 'US', created_at: '2024-09-06T12:00:00Z') # Game1, US, 2024, 2024-09, 2024-09-08

      create(:server_vote, server: server, game: game1, country_code: 'BR', created_at: '2024-09-07T12:00:00Z') # Game1, BR, 2024, 2024-09, 2024-09-08
      create(:server_vote, server: server, game: game1, country_code: 'BR', created_at: '2024-09-08T12:00:00Z') # Game1, BR, 2024, 2024-09, 2024-09-08

      create(:server_vote, server: server, game: game2, country_code: 'BR', created_at: '2024-09-08T15:00:00Z') # Game2, BR, 2024, 2024-09, 2024-09-08
      create(:server_vote, server: server, game: game2, country_code: 'BR', created_at: '2024-09-08T18:00:00Z') # Game2, BR, 2024, 2024-09, 2024-09-08

      server_stat_assertions = proc do
        expect(ServerStat.find_by!(period: 'year', reference_date: '2023-12-31', game: game1, country_code: 'US',  server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2023-12-31', game: game1, country_code: 'all', server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game1, country_code: 'US',  server: server).vote_count).to eq(5)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game1, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game1, country_code: 'all', server: server).vote_count).to eq(7)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game2, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game2, country_code: 'all', server: server).vote_count).to eq(2)

        expect(ServerStat.find_by!(period: 'month', reference_date: '2023-12-31', game: game1, country_code: 'US',  server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2023-12-31', game: game1, country_code: 'all', server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-01-31', game: game1, country_code: 'US',  server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-01-31', game: game1, country_code: 'all', server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-03-31', game: game1, country_code: 'US',  server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-03-31', game: game1, country_code: 'all', server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game1, country_code: 'US',  server: server).vote_count).to eq(3)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game1, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game1, country_code: 'all', server: server).vote_count).to eq(5)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game2, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game2, country_code: 'all', server: server).vote_count).to eq(2)

        expect(ServerStat.find_by!(period: 'week', reference_date: '2023-12-31', game: game1, country_code: 'US',  server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2023-12-31', game: game1, country_code: 'all', server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-01-07', game: game1, country_code: 'US',  server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-01-07', game: game1, country_code: 'all', server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-03-03', game: game1, country_code: 'US',  server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-03-03', game: game1, country_code: 'all', server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-01', game: game1, country_code: 'US',  server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-01', game: game1, country_code: 'all', server: server).vote_count).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game1, country_code: 'US',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game1, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game1, country_code: 'all', server: server).vote_count).to eq(4)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game2, country_code: 'BR',  server: server).vote_count).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game2, country_code: 'all', server: server).vote_count).to eq(2)
      end

      travel_to(current_time) do
        expect do
          described_class.new(server).process_all
        end.to change(ServerStat, :count).by(31)

        expect(ServerStat.where(vote_count_consolidated_at: current_time).count).to eq(31)
        server_stat_assertions.call
      end

      travel_to(current_time + 1.hour) do
        expect do
          described_class.new(server).process_all
        end.not_to change(ServerStat, :count)

        expect(ServerStat.where(vote_count_consolidated_at: current_time + 1.hour).count).to eq(31)
        server_stat_assertions.call
      end
    end
  end
end
