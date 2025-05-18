require 'rails_helper'

RSpec.describe Servers::ConsolidateRankings do
  around do |example|
    EnvVarHelper.with_values('PERIODS_MIN_PAST_TIME' => '2023-01-01T00:00:00Z') do
      example.run
    end
  end

  describe '#process_current' do
    it 'consolidates rankings for the current year, month, week' do
      current_time = Time.iso8601('2024-09-08T18:00:00Z')
      game = create(:game)
      server1 = create(:server)
      server2 = create(:server)
      server3 = create(:server)

      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2023-12-31T23:59:59Z') # Server1, US, NOT current year, NOT current month, NOT current week
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-01-01T00:00:00Z') # Server1, US, current year,     NOT current month, NOT current week
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-03-01T12:00:00Z') # Server1, US, current year,     NOT current month, NOT current week
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-04-01T12:00:00Z') # Server1, US, current year,     NOT current month, NOT current week
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-09-01T23:59:59Z') # Server1, US, current year,     current month,     NOT current week
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-09-02T00:00:00Z') # Server1, US, current year,     current month,     current week
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-09-06T12:00:00Z') # Server1, US, current year,     current month,     current week
      create(:server_vote, server: server1, game: game, country_code: 'BR', created_at: '2024-09-07T12:00:00Z') # Server1, BR, current year,     current month,     current week
      create(:server_vote, server: server1, game: game, country_code: 'BR', created_at: '2024-09-08T12:00:00Z') # Server1, BR, current year,     current month,     current week

      create(:server_vote, server: server2, game: game, country_code: 'US', created_at: '2024-01-01T00:00:00Z') # Server2, US, current year,     NOT current month, NOT current week
      create(:server_vote, server: server2, game: game, country_code: 'US', created_at: '2024-01-02T00:00:00Z') # Server2, US, current year,     NOT current month, NOT current week
      create(:server_vote, server: server2, game: game, country_code: 'US', created_at: '2024-01-03T00:00:00Z') # Server2, US, current year,     NOT current month, NOT current week
      create(:server_vote, server: server2, game: game, country_code: 'US', created_at: '2024-01-04T00:00:00Z') # Server2, US, current year,     NOT current month, NOT current week

      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T12:00:00Z') # Server3, US, current year,     current month,     NOT current week
      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T13:00:00Z') # Server3, US, current year,     current month,     NOT current week
      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T14:00:00Z') # Server3, US, current year,     current month,     NOT current week
      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T15:00:00Z') # Server3, US, current year,     current month,     NOT current week
      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T23:59:59Z') # Server3, US, current year,     current month,     NOT current week

      server_stat_assertions = proc do
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'US',  server: server3).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'US',  server: server2).ranking_number).to eq(3)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'BR',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'all', server: server3).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'all', server: server2).ranking_number).to eq(3)

        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'US',  server: server3).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'US',  server: server1).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'BR',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'all', server: server3).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'all', server: server1).ranking_number).to eq(2)

        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game, country_code: 'BR',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
      end

      travel_to(current_time) do
        expect do
          Servers::ConsolidateVoteCounts.new(server1).process_current
          Servers::ConsolidateVoteCounts.new(server2).process_current
          Servers::ConsolidateVoteCounts.new(server3).process_current
        end.to change(ServerStat, :count).by(15)

        expect do
          described_class.new(game).process_current
        end.not_to change(ServerStat, :count)

        expect(ServerStat.where(ranking_number_consolidated_at: current_time).count).to eq(15)
        server_stat_assertions.call
      end

      travel_to(current_time + 1.hour) do
        expect do
          Servers::ConsolidateVoteCounts.new(server1).process_current
          Servers::ConsolidateVoteCounts.new(server2).process_current
          Servers::ConsolidateVoteCounts.new(server3).process_current
        end.not_to change(ServerStat, :count)

        expect do
          described_class.new(game).process_current
        end.not_to change(ServerStat, :count)

        expect(ServerStat.where(ranking_number_consolidated_at: current_time + 1.hour).count).to eq(15)
        server_stat_assertions.call
      end
    end
  end

  describe '#process_all' do
    it 'consolidates rankings for all years, months, weeks' do
      current_time = Time.iso8601('2024-09-08T18:00:00Z')
      game = create(:game)
      server1 = create(:server)
      server2 = create(:server)
      server3 = create(:server)

      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2023-12-31T23:59:59Z') # Server1, US, 2023, 2023-12, 2023-12-31
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-01-01T00:00:00Z') # Server1, US, 2024, 2024-01, 2024-01-07
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-03-01T12:00:00Z') # Server1, US, 2024, 2024-03, 2024-03-03
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-04-01T12:00:00Z') # Server1, US, 2024, 2024-04, 2024-04-07
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-09-01T23:59:59Z') # Server1, US, 2024, 2024-09, 2024-09-01
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-09-02T00:00:00Z') # Server1, US, 2024, 2024-09, 2024-09-08
      create(:server_vote, server: server1, game: game, country_code: 'US', created_at: '2024-09-06T12:00:00Z') # Server1, US, 2024, 2024-09, 2024-09-08
      create(:server_vote, server: server1, game: game, country_code: 'BR', created_at: '2024-09-07T12:00:00Z') # Server1, BR, 2024, 2024-09, 2024-09-08
      create(:server_vote, server: server1, game: game, country_code: 'BR', created_at: '2024-09-08T12:00:00Z') # Server1, BR, 2024, 2024-09, 2024-09-08

      create(:server_vote, server: server2, game: game, country_code: 'US', created_at: '2024-01-01T00:00:00Z') # Server2, US, 2024, 2024-01, 2024-01-07
      create(:server_vote, server: server2, game: game, country_code: 'US', created_at: '2024-01-02T00:00:00Z') # Server2, US, 2024, 2024-01, 2024-01-07
      create(:server_vote, server: server2, game: game, country_code: 'US', created_at: '2024-01-03T00:00:00Z') # Server2, US, 2024, 2024-01, 2024-01-07
      create(:server_vote, server: server2, game: game, country_code: 'US', created_at: '2024-01-04T00:00:00Z') # Server2, US, 2024, 2024-01, 2024-01-07

      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T12:00:00Z') # Server3, US, 2024, 2024-09, 2024-09-01
      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T13:00:00Z') # Server3, US, 2024, 2024-09, 2024-09-01
      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T14:00:00Z') # Server3, US, 2024, 2024-09, 2024-09-01
      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T15:00:00Z') # Server3, US, 2024, 2024-09, 2024-09-01
      create(:server_vote, server: server3, game: game, country_code: 'US', created_at: '2024-09-01T23:59:59Z') # Server3, US, 2024, 2024-09, 2024-09-01

      server_stat_assertions = proc do
        expect(ServerStat.find_by!(period: 'year', reference_date: '2023-12-31', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2023-12-31', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'US',  server: server3).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'US',  server: server2).ranking_number).to eq(3)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'BR',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'all', server: server3).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'year', reference_date: '2024-12-31', game: game, country_code: 'all', server: server2).ranking_number).to eq(3)

        expect(ServerStat.find_by!(period: 'month', reference_date: '2023-12-31', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2023-12-31', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-01-31', game: game, country_code: 'US',  server: server2).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-01-31', game: game, country_code: 'US',  server: server1).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-01-31', game: game, country_code: 'all', server: server2).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-01-31', game: game, country_code: 'all', server: server1).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-03-31', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-03-31', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-04-30', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-04-30', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'US',  server: server3).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'US',  server: server1).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'BR',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'all', server: server3).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'month', reference_date: '2024-09-30', game: game, country_code: 'all', server: server1).ranking_number).to eq(2)

        expect(ServerStat.find_by!(period: 'week', reference_date: '2023-12-31', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2023-12-31', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-01-07', game: game, country_code: 'US',  server: server2).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-01-07', game: game, country_code: 'US',  server: server1).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-01-07', game: game, country_code: 'all', server: server2).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-01-07', game: game, country_code: 'all', server: server1).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-03-03', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-03-03', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-04-07', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-04-07', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-01', game: game, country_code: 'US',  server: server3).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-01', game: game, country_code: 'US',  server: server1).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-01', game: game, country_code: 'all', server: server3).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-01', game: game, country_code: 'all', server: server1).ranking_number).to eq(2)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game, country_code: 'US',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game, country_code: 'BR',  server: server1).ranking_number).to eq(1)
        expect(ServerStat.find_by!(period: 'week', reference_date: '2024-09-08', game: game, country_code: 'all', server: server1).ranking_number).to eq(1)
      end

      travel_to(current_time) do
        expect do
          Servers::ConsolidateVoteCounts.new(server1).process_all
          Servers::ConsolidateVoteCounts.new(server2).process_all
          Servers::ConsolidateVoteCounts.new(server3).process_all
        end.to change(ServerStat, :count).by(41)

        expect do
          described_class.new(game).process_all
        end.not_to change(ServerStat, :count)

        expect(ServerStat.where(ranking_number_consolidated_at: current_time).count).to eq(41)
        server_stat_assertions.call
      end

      travel_to(current_time + 1.hour) do
        expect do
          Servers::ConsolidateVoteCounts.new(server1).process_all
          Servers::ConsolidateVoteCounts.new(server2).process_all
          Servers::ConsolidateVoteCounts.new(server3).process_all
        end.not_to change(ServerStat, :count)

        expect do
          described_class.new(game).process_all
        end.not_to change(ServerStat, :count)

        expect(ServerStat.where(ranking_number_consolidated_at: current_time + 1.hour).count).to eq(41)
        server_stat_assertions.call
      end
    end
  end
end
