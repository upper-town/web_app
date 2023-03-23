# frozen_string_literal: true

module Servers
  class ConsolidateVoteCounts
    def initialize(server)
      @server = server
    end

    def process_all
      past_time = ServerStat::MIN_PAST_TIME
      current_time = Time.current

      process(past_time, current_time)
    end

    def process_current
      current_time = Time.current

      process(current_time, current_time)
    end

    private

    def process(past_time, current_time)
      # TODO: Consider acquiring a lock on @server just to we don't run more than
      # one instance of this service simultaneously for the same server

      ServerStat::PERIODS.each do |period|
        ServerStat.loop_through(period, past_time, current_time) do |reference_date, reference_range|
          upsert_country_server_stats(period, reference_date, reference_range)
          upsert_global_server_stats(period, reference_date, reference_range)
        end
      end
    end

    def upsert_country_server_stats(period, reference_date, reference_range)
      country_app_vote_counts = query_country_server_vote_counts(reference_range)
      consolidated_at = Time.current

      server_stat_hashes = country_app_vote_counts.map do |(app_id, country_code), country_vote_count|
        {
          period: period,
          reference_date: reference_date,
          app_id: app_id,
          country_code: country_code,
          server_id: @server.id,
          vote_count: country_vote_count,
          vote_count_consolidated_at: consolidated_at,
        }
      end

      server_stat_upsert_all(server_stat_hashes) if server_stat_hashes.any?
    end

    def upsert_global_server_stats(period, reference_date, reference_range)
      global_app_vote_counts = query_global_server_vote_counts(reference_range)
      consolidated_at = Time.current

      server_stat_hashes = global_app_vote_counts.map do |app_id, global_vote_count|
        {
          period: period,
          reference_date: reference_date,
          app_id: app_id,
          country_code: ServerStat::GLOBAL,
          server_id: @server.id,
          vote_count: global_vote_count,
          vote_count_consolidated_at: consolidated_at,
        }
      end

      server_stat_upsert_all(server_stat_hashes) if server_stat_hashes.any?
    end

    # rubocop:disable Rails/SkipsModelValidations
    def server_stat_upsert_all(server_stat_hashes)
      ServerStat.upsert_all(
        server_stat_hashes,
        unique_by: [
          :period,
          :reference_date,
          :app_id,
          :country_code,
          :server_id,
        ]
      )
    end
    # rubocop:enable Rails/SkipsModelValidations

    def query_country_server_vote_counts(reference_range)
      ServerVote
        .where(server: @server)
        .where(created_at: reference_range)
        .group(:app_id, :country_code)
        .count
    end

    def query_global_server_vote_counts(reference_range)
      ServerVote
        .where(server: @server)
        .where(created_at: reference_range)
        .group(:app_id)
        .count
    end
  end
end
