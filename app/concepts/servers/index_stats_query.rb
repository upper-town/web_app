# frozen_string_literal: true

module Servers
  class IndexStatsQuery
    def initialize(server_ids, country_code = nil, current_time = nil)
      @server_ids = server_ids
      @country_code = country_code || ServerStat::GLOBAL
      @current_time = current_time || Time.current
    end

    def call
      scope = Server.where(id: @server_ids)

      scope = scope.joins(sql_left_join)
      scope = scope.where(sql_conditions_app_id)
      scope = scope.where(sql_conditions_country_code)
      scope = scope.where(sql_conditions_period_reference_date)
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
          hash[server_joined_stat.stat_period] = ServerStat.new(
            period:         server_joined_stat.stat_period,
            ranking_number: server_joined_stat.stat_ranking_number,
            vote_count:     server_joined_stat.stat_vote_count,
          )
        end
      end
    end

    def sql_left_join
      <<-SQL.squish
        LEFT OUTER JOIN "server_stats" ON
          "server_stats"."server_id" = "servers"."id"
      SQL
    end

    def sql_conditions_app_id
      <<-SQL.squish
        (
          "server_stats"."app_id" = "servers"."app_id" OR
          "server_stats"."app_id" IS NULL
        )
      SQL
    end

    def sql_conditions_country_code
      if @country_code == ServerStat::GLOBAL
        <<-SQL.squish
          (
            "server_stats"."country_code" = #{quote_for_sql(ServerStat::GLOBAL)} OR
            "server_stats"."country_code" IS NULL
          )
        SQL
      else
        <<-SQL.squish
          (
            "server_stats"."country_code" = "servers"."country_code" OR
            "server_stats"."country_code" IS NULL
          )
        SQL
      end
    end

    def sql_conditions_period_reference_date
      conditions = ServerStat::PERIODS.map do |period|
        <<-SQL.squish
          (
            "server_stats"."period" = #{quote_for_sql(period)} AND
            "server_stats"."reference_date" = #{quote_for_sql(ServerStat.reference_date_for(period, @current_time))}
          )
        SQL
      end
      conditions.push(
        <<-SQL.squish
          (
            "server_stats"."period" IS NULL AND
            "server_stats"."reference_date" IS NULL
          )
        SQL
      )

      conditions.join(' OR ')
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
