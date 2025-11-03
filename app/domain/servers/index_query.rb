# frozen_string_literal: true

module Servers
  class IndexQuery
    include Callable

    attr_reader :game, :period, :country_codes, :current_time

    def initialize(game = nil, period = nil, country_codes = nil, current_time = nil)
      @game = game
      @period = period || Periods::MONTH
      @country_codes = build_country_codes(country_codes)
      @current_time = current_time || Time.current
    end

    def call
      scope = Server.includes(:game)
      scope = scope.where(game:) if game.present?
      scope = scope.where(country_code: country_codes) if country_codes
      scope = scope.joins(sql_left_join_server_stats)

      scope.order(sql_order)
    end

    private

    def sql_left_join_server_stats
      <<~SQL
        LEFT JOIN "server_stats" ON
              "server_stats"."server_id" = "servers"."id"
          AND "server_stats"."game_id"   = "servers"."game_id"
          AND #{sql_on_period_and_reference_date}
      SQL
    end

    def sql_on_period_and_reference_date
      <<~SQL
            "server_stats"."period"         = #{quote_for_sql(period)}
        AND "server_stats"."reference_date" = #{quote_for_sql(Periods.reference_date_for(period, current_time))}
      SQL
    end

    def sql_order
      <<~SQL
        "server_stats"."ranking_number" ASC,
        "server_stats"."vote_count"     DESC,
        "servers"."id"                  DESC
      SQL
    end

    def quote_for_sql(value)
      ActiveRecord::Base.connection.quote(value)
    end

    def build_country_codes(values)
      return if values.nil?

      values.select { Server::COUNTRY_CODES.include?(it) }
    end
  end
end
