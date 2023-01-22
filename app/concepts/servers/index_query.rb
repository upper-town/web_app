# frozen_string_literal: true

module Servers
  class IndexQuery
    def initialize(app = nil, period = nil, country_code = nil, current_time = nil)
      @app = app
      @period = period || ServerStat::YEAR
      @country_code = country_code || ServerStat::GLOBAL
      @current_time = current_time || Time.current
    end

    def call
      scope = Server.includes(:app)
      scope = scope.where(app: @app) if @app.present?
      scope = scope.where(country_code: @country_code) if Server::COUNTRY_CODES.include?(@country_code)

      scope = scope.joins(sql_left_join)
      scope = scope.where(sql_conditions_period_reference_date)
      scope = scope.where(sql_conditions_app_id)
      scope = scope.where(sql_conditions_country_code)

      scope.order(sql_order)
    end

    private

    def sql_left_join
      <<-SQL.squish
        LEFT OUTER JOIN "server_stats" ON
          "server_stats"."server_id" = "servers"."id"
      SQL
    end

    def sql_conditions_period_reference_date
      <<-SQL.squish
        (
          "server_stats"."period" = #{quote_for_sql(@period)} AND
          "server_stats"."reference_date" = #{quote_for_sql(ServerStat.reference_date_for(@period, @current_time))}
        ) OR (
          "server_stats"."period" IS NULL AND
          "server_stats"."reference_date" IS NULL
        )
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

    def sql_order
      <<-SQL.squish
        "server_stats"."period",
        "server_stats"."ranking_number" ASC,
        "servers"."app_id" ASC
      SQL
    end

    def quote_for_sql(value)
      ActiveRecord::Base.connection.quote(value)
    end
  end
end
