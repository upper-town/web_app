# frozen_string_literal: true

module Servers
  class IndexStatsQuery
    def initialize(server_ids, country_code = nil, current_time = nil)
      @server_ids   = server_ids
      @country_code = country_code || ServerStat::ALL
      @current_time = current_time || Time.current
    end

    def call
      scope = Server.where(id: @server_ids)
      scope = scope.joins(sql_left_join_server_stats)
      scope = scope.select(sql_select_fields)

      build_server_stats_hash(scope)
    end

    private

    # server_stats_hash has the following format:
    #
    # {
    #   <#Interger (Server.id)> => {
    #     "year"  => <#ServerStat (year))>,
    #     "month" => <#ServerStat (month))>,
    #     "day"   => <#ServerStat (year))>,
    #   },
    #   ...
    # }
    def build_server_stats_hash(servers_joined_stats)
      servers_joined_stats.group_by(&:id).transform_values do |values|
        values.each_with_object(Hash.new { ServerStat.new }) do |server_joined_stat, hash|
          next if server_joined_stat.stat_period.nil?

          hash[server_joined_stat.stat_period] = ServerStat.new(
            period:         server_joined_stat.stat_period,
            ranking_number: server_joined_stat.stat_ranking_number,
            vote_count:     server_joined_stat.stat_vote_count,
          )
        end
      end
    end

    def sql_left_join_server_stats
      <<-SQL.squish
        LEFT JOIN "server_stats" ON
              "server_stats"."server_id" = "servers"."id"
          AND "server_stats"."app_id"    = "servers"."app_id"
          AND #{sql_on_periods_and_reference_dates}
          AND #{sql_on_country_code}
      SQL
    end

    def sql_on_periods_and_reference_dates
      conditions = ServerStat::PERIODS.map do |period|
        <<-SQL.squish
              "server_stats"."period"         = #{quote_for_sql(period)}
          AND "server_stats"."reference_date" = #{quote_for_sql(ServerStat.reference_date_for(period, @current_time))}
        SQL
      end

      "( #{conditions.join(' OR ')} )"
    end

    def sql_on_country_code
      <<-SQL.squish
        "server_stats"."country_code" = #{
          @country_code == ServerStat::ALL ? quote_for_sql(ServerStat::ALL) : '"servers"."country_code"'
        }
      SQL
    end

    def sql_select_fields
      <<-SQL.squish
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
