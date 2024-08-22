# frozen_string_literal: true

module Servers
  class ConsolidateVoteCounts
    attr_reader :server

    def initialize(server)
      @server = server
    end

    def process_all
      current_time = Time.current

      process(nil, current_time)
    end

    def process_current
      current_time = Time.current

      process(current_time, current_time)
    end

    private

    def process(past_time, current_time)
      # TODO: Consider acquiring a lock on server just to we don't run more than
      # one instance of this service simultaneously for the same server

      ServerStat::PERIODS.each do |period|
        ServerStat.loop_through(period, past_time, current_time) do |reference_date, reference_range|
          upsert_country_server_stats(period, reference_date, reference_range)
          upsert_all_server_stats(period, reference_date, reference_range)
        end
      end
    end

    def upsert_country_server_stats(period, reference_date, reference_range)
      country_game_vote_counts = query_country_server_vote_counts(reference_range)
      consolidated_at = Time.current

      server_stat_hashes = country_game_vote_counts.map do |(game_id, country_code), country_vote_count|
        {
          period: period,
          reference_date: reference_date,
          game_id: game_id,
          country_code: country_code,
          server_id: server.id,
          vote_count: country_vote_count,
          vote_count_consolidated_at: consolidated_at,
        }
      end

      server_stat_upsert_all(server_stat_hashes) if server_stat_hashes.any?
    end

    def upsert_all_server_stats(period, reference_date, reference_range)
      all_game_vote_counts = query_all_server_vote_counts(reference_range)
      consolidated_at = Time.current

      server_stat_hashes = all_game_vote_counts.map do |game_id, all_vote_count|
        {
          period: period,
          reference_date: reference_date,
          game_id: game_id,
          country_code: ServerStat::ALL,
          server_id: server.id,
          vote_count: all_vote_count,
          vote_count_consolidated_at: consolidated_at,
        }
      end

      server_stat_upsert_all(server_stat_hashes) if server_stat_hashes.any?
    end

    def server_stat_upsert_all(server_stat_hashes)
      ServerStat.upsert_all(
        server_stat_hashes,
        unique_by: [
          :period,
          :reference_date,
          :game_id,
          :country_code,
          :server_id,
        ]
      )
    end

    def query_country_server_vote_counts(reference_range)
      ServerVote
        .where(server: server)
        .where(created_at: reference_range)
        .group(:game_id, :country_code)
        .count
    end

    def query_all_server_vote_counts(reference_range)
      ServerVote
        .where(server: server)
        .where(created_at: reference_range)
        .group(:game_id)
        .count
    end
  end
end
