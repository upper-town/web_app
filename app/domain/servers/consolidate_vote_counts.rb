# frozen_string_literal: true

module Servers
  class ConsolidateVoteCounts
    attr_reader :server

    def initialize(server)
      @server = server
    end

    def process_current
      current_time = Time.current

      process(current_time, current_time)
    end

    def process_all
      current_time = Time.current

      process(nil, current_time)
    end

    def process(past_time, current_time)
      Periods::PERIODS.each do |period|
        Periods.loop_through(period, past_time, current_time) do |reference_date, reference_range|
          upsert_server_stats_per_country_code(period, reference_date, reference_range)
          upsert_server_stats_all(period, reference_date, reference_range)
        end
      end
    end

    private

    def upsert_server_stats_per_country_code(period, reference_date, reference_range)
      game_country_code_vote_counts = game_country_code_vote_counts_query(reference_range)
      vote_count_consolidated_at = Time.current

      server_stat_hashes = game_country_code_vote_counts.map do |(game_id, country_code), vote_count|
        {
          period:,
          reference_date:,
          game_id:,
          country_code:,
          server_id: server.id,
          vote_count:,
          vote_count_consolidated_at:
        }
      end

      server_stat_upsert(server_stat_hashes) unless server_stat_hashes.empty?
    end

    def upsert_server_stats_all(period, reference_date, reference_range)
      game_vote_counts = game_vote_counts_query(reference_range)
      vote_count_consolidated_at = Time.current

      server_stat_hashes = game_vote_counts.map do |game_id, vote_count|
        {
          period:,
          reference_date:,
          game_id:,
          country_code: ServerStat::ALL,
          server_id: server.id,
          vote_count:,
          vote_count_consolidated_at:
        }
      end

      server_stat_upsert(server_stat_hashes) unless server_stat_hashes.empty?
    end

    def server_stat_upsert(server_stat_hashes)
      ServerStat.upsert_all(
        server_stat_hashes,
        unique_by: [
          :period,
          :reference_date,
          :game_id,
          :country_code,
          :server_id
        ]
      )
    end

    def game_country_code_vote_counts_query(reference_range)
      ServerVote
        .where(server:)
        .where(created_at: reference_range)
        .group(:game_id, :country_code)
        .count
    end

    def game_vote_counts_query(reference_range)
      ServerVote
        .where(server:)
        .where(created_at: reference_range)
        .group(:game_id)
        .count
    end
  end
end
