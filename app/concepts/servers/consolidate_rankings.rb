# frozen_string_literal: true

module Servers
  class ConsolidateRankings
    attr_reader :game

    def initialize(game)
      @game = game
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
      # TODO: Consider acquiring a lock on game just to we don't run more than
      # one instance of this service simultaneously for the same game

      ServerStat::PERIODS.each do |period|
        ServerStat.loop_through(period, past_time, current_time) do |reference_date, _|
          upsert_server_stats(period, reference_date)
        end
      end
    end

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

    def query_server_stat_values(period, reference_date)
      ServerStat
        .where(period: period, reference_date: reference_date, game: game)
        .where.not(vote_count_consolidated_at: nil)
        .order(:country_code, vote_count: :desc)
        .pluck(:country_code, :id)
        .group_by { |country_code, _id| country_code }
    end
  end
end
