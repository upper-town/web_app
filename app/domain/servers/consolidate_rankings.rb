# frozen_string_literal: true

module Servers
  class ConsolidateRankings
    include Callable

    attr_reader :game, :periods, :past_time, :current_time

    def initialize(game, periods = nil, past_time = nil, current_time = nil)
      @game = game
      @periods = periods || Periods::PERIODS
      @past_time = past_time
      @current_time = current_time
    end

    def call
      periods.each do |period|
        Periods.loop_through(period, past_time, current_time) do |reference_date, _reference_range|
          update_server_stats(period, reference_date)
        end
      end
    end

    private

    def update_server_stats(period, reference_date)
      ordered_server_stats = ordered_server_stats_query(period, reference_date)
      ranking_number_consolidated_at = Time.current

      ordered_server_stats.each.with_index(1) do |id, index|
        ServerStat
          .where(id:)
          .update_all(
            ranking_number: index,
            ranking_number_consolidated_at:
          )
      end
    end

    def ordered_server_stats_query(period, reference_date)
      ServerStat
        .where(period:, reference_date:, game:)
        .where.not(vote_count_consolidated_at: nil)
        .order(vote_count: :desc, id: :desc)
        .pluck(:id)
    end
  end
end
