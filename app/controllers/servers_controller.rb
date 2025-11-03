# frozen_string_literal: true

class ServersController < ApplicationController
  def index
    current_time = Time.current

    @game = game_from_params
    @period = period_from_params
    @country_codes = country_codes_from_params

    @selected_value_game_id = @game ? @game.id : nil
    @selected_value_period = @period
    @selected_value_country_codes = @country_codes ? @country_codes.join(",") : nil

    @pagination = Pagination.new(
      Servers::IndexQuery.new(@game, @period, @country_codes, current_time).call,
      request,
      per_page: 10
    )

    @servers = @pagination.results
    @server_stats_hash = Servers::IndexStatsQuery.new(@servers.pluck(:id), current_time).call

    render(status: :ok)
  rescue InvalidQueryParamError
    @servers = []
    @server_stats_hash = {}

    render(status: :not_found)
  end

  def show
    @server = server_from_params
  end

  private

  def game_from_params
    value = params[:game_id]

    if value.blank?
      nil
    elsif (game = Game.find_by(id: value))
      game
    else
      raise InvalidQueryParamError
    end
  end

  def period_from_params
    value = params[:period]

    if value.blank?
      Periods::MONTH
    elsif Periods::PERIODS.include?(value)
      value
    else
      raise InvalidQueryParamError
    end
  end

  def country_codes_from_params
    values = StringHelper.values_list_uniq(params[:country_codes] || "")

    if values.empty?
      nil
    elsif values.all? { Server::COUNTRY_CODES.include?(it) }
      values
    else
      raise InvalidQueryParamError
    end
  end

  def server_from_params
    Server.find(params[:id])
  end
end
