# frozen_string_literal: true

module Servers
  class StatsConsolidator
    include Callable

    attr_reader :periods, :time

    def initialize(periods = nil, time = nil)
      @periods = periods || Periods::PERIODS
      @time = time || Time.current
    end

    def call
      servers = Server
        .distinct
        .joins(:votes)
        .left_joins(:stats)
        .where(
          server_votes: { created_at: ..time },
          server_stats: { reference_date: }
        )
        .group(:id)
        .having(
          'MAX(COALESCE("server_stats"."vote_count_consolidated_at", ?)) < MAX("server_votes"."created_at")',
          Periods.min_past_time
        )

      game_ids = []
      servers.find_each do |server|
        ConsolidateVoteCounts.call(server, periods, time)
        game_ids << server.game_id
      end

      Game.where(id: game_ids.uniq).find_each do |game|
        ConsolidateRankings.call(game, periods, time)
      end
    end

    private

    def reference_date
      periods.map do |period|
        Periods.reference_date_for(period, time)
      end.push(nil)
    end
  end
end
