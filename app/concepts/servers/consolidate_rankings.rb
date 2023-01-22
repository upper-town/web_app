# frozen_string_literal: true

module Servers
  class ConsolidateRankings
    def initialize(app)
      @app = app
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
      ServerStat::PERIODS.each do |period|
        ServerStat.loop_through(period, past_time, current_time) do |reference_date, _|
          upsert_server_stats(period, reference_date)
        end
      end
    end

    # rubocop:disable Rails/SkipsModelValidations
    def upsert_server_stats(period, reference_date)
      ordered_grouped_server_stat_values = query_server_stat_values(period, reference_date)
      consolidated_at = Time.current

      ordered_grouped_server_stat_values.each do |_country_code, values|
        values.map.with_index(1) do |(_country_code, id), index|
          ServerStat.where(
            id: id
          ).update_all(
            ranking_number: index,
            ranking_number_consolidated_at: consolidated_at,
          )
        end
      end
    end
    # rubocop:enable Rails/SkipsModelValidations

    def query_server_stat_values(period, reference_date)
      ServerStat
        .where(period: period, reference_date: reference_date, app: @app)
        .where.not(vote_count_consolidated_at: nil)
        .order(:country_code, vote_count: :desc)
        .pluck(:country_code, :id)
        .group_by { |country_code, _id| country_code }
    end
  end
end
