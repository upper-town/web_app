# frozen_string_literal: true

module Servers
  class IndexQuery
    include Callable

    attr_reader :game, :period, :country_code, :current_time

    def initialize(game = nil, period = nil, country_code = nil, current_time = nil)
      @game = game
      @period = period || Periods::MONTH
      @country_code = country_code || ServerStat::ALL
      @current_time = current_time || Time.current
    end

    def call
      scope = Server.includes(:game)
      scope = scope.where(game: game) if game.present?
      scope = scope.where(country_code: country_code) if Server::COUNTRY_CODES.include?(country_code)
      scope = scope.joins(sql_left_join_server_stats)

      scope.order(sql_order)
    end

    private

    def sql_left_join_server_stats
      <<-SQL.squish
        LEFT JOIN "server_stats" ON
              "server_stats"."server_id" = "servers"."id"
          AND "server_stats"."game_id"   = "servers"."game_id"
          AND #{sql_on_period_and_reference_date}
          AND #{sql_on_country_code}
      SQL
    end

    def sql_on_period_and_reference_date
      <<-SQL.squish
            "server_stats"."period"         = #{quote_for_sql(period)}
        AND "server_stats"."reference_date" = #{quote_for_sql(Periods.reference_date_for(period, current_time))}
      SQL
    end

    def sql_on_country_code
      <<-SQL.squish
        "server_stats"."country_code" = #{
          country_code == ServerStat::ALL ? quote_for_sql(ServerStat::ALL) : '"servers"."country_code"'
        }
      SQL
    end

    def sql_order
      <<-SQL.squish
        "server_stats"."ranking_number" ASC,
        "server_stats"."vote_count"     DESC,
        "servers"."id"                  DESC
      SQL
    end

    def quote_for_sql(value)
      ActiveRecord::Base.connection.quote(value)
    end
  end
end
