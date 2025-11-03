# frozen_string_literal: true

module Servers
  class ConsolidateVoteCounts
    include Callable

    attr_reader :server, :periods, :past_time, :current_time

    def initialize(server, periods = nil, past_time = nil, current_time = nil)
      @server = server
      @periods = periods || Periods::PERIODS
      @past_time = past_time
      @current_time = current_time
    end

    def call
      periods.each do |period|
        Periods.loop_through(period, past_time, current_time) do |reference_date, reference_range|
          upsert_server_stats(period, reference_date, reference_range)
        end
      end
    end

    private

    def upsert_server_stats(period, reference_date, reference_range)
      game_vote_counts = game_vote_counts_query(reference_range)
      vote_count_consolidated_at = Time.current

      server_stat_hashes = game_vote_counts.map do |game_id, vote_count|
        {
          period:,
          reference_date:,
          game_id:,
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
          :server_id
        ]
      )
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
