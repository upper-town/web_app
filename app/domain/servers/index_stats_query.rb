# frozen_string_literal: true

module Servers
  class IndexStatsQuery
    include Callable

    attr_reader :server_ids, :current_time

    def initialize(server_ids, current_time = nil)
      @server_ids   = server_ids
      @current_time = current_time || Time.current
    end

    def call
      scope = Server.where(id: server_ids)
      scope = scope.joins(sql_left_join_server_stats)
      scope = scope.select(sql_select_fields)

      build_server_stats_hash(scope)
    end

    private

    # server_stats_hash has the following format:
    #
    # {
    #   <#Interger (Server.id)> => {
    #     "year"  => { ranking_number: <#Interger>, vote_count: <#Interger> },
    #     "month" => { ranking_number: <#Interger>, vote_count: <#Interger> },
    #     "week"  => { ranking_number: <#Interger>, vote_count: <#Interger> },
    #   },
    #   ...
    # }
    def build_server_stats_hash(servers_joined_stats)
      servers_joined_stats.each_with_object({}) do |row, hash|
        next unless row.stat_period

        hash[row.id] ||= {}
        hash[row.id][row.stat_period] = {
          ranking_number: row.stat_ranking_number,
          vote_count:     row.stat_vote_count
        }
      end
    end

    def sql_left_join_server_stats
      <<~SQL
        LEFT JOIN "server_stats" ON
              "server_stats"."server_id" = "servers"."id"
          AND "server_stats"."game_id"   = "servers"."game_id"
          AND #{sql_on_periods_and_reference_dates}
      SQL
    end

    def sql_on_periods_and_reference_dates
      conditions = Periods::PERIODS.map do |period|
        <<~SQL
              "server_stats"."period"         = #{quote_for_sql(period)}
          AND "server_stats"."reference_date" = #{quote_for_sql(Periods.reference_date_for(period, current_time))}
        SQL
      end

      "( #{conditions.join(' OR ')} )"
    end

    def sql_select_fields
      <<~SQL
        "servers"."id",
        "server_stats"."period"         AS "stat_period",
        "server_stats"."ranking_number" AS "stat_ranking_number",
        "server_stats"."vote_count"     AS "stat_vote_count"
      SQL
    end

    def quote_for_sql(value)
      ActiveRecord::Base.connection.quote(value)
    end
  end
end
