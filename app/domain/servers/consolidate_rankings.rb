# frozen_string_literal: true

module Servers
  class ConsolidateRankings
    attr_reader :game

    def initialize(game)
      @game = game
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
        Periods.loop_through(period, past_time, current_time) do |reference_date, _reference_range|
          update_server_stats(period, reference_date)
        end
      end
    end

    private

    def update_server_stats(period, reference_date)
      ordered_grouped_server_stats = ordered_grouped_server_stats_query(period, reference_date)
      ranking_number_consolidated_at = Time.current

      ordered_grouped_server_stats.each do |_country_code, values|
        values.each.with_index(1) do |(_country_code, id), index|
          ServerStat
            .where(id: id)
            .update_all(
              ranking_number: index,
              ranking_number_consolidated_at: ranking_number_consolidated_at
            )
        end
      end
    end

    def ordered_grouped_server_stats_query(period, reference_date)
      ServerStat
        .where(period: period, reference_date: reference_date, game: game)
        .where.not(vote_count_consolidated_at: nil)
        .order(:country_code, vote_count: :desc, id: :desc)
        .pluck(:country_code, :id)
        .group_by { |country_code, _id| country_code }
    end
  end
end
