class ServersController < ApplicationController
  def index
    current_time = Time.current

    @game = game_from_params
    @period = period_from_params
    @country_code = country_code_from_params

    @selected_value_game_id = @game ? @game.id : nil
    @selected_value_period = @period
    @selected_value_country_code = @country_code

    @pagination = Pagination.new(
      Servers::IndexQuery.new(@game, @period, @country_code, current_time).call,
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
    if params[:game_id].blank?
      nil
    elsif (game = Game.find_by(id: params[:game_id]))
      game
    else
      raise InvalidQueryParamError
    end
  end

  def period_from_params
    if params[:period].blank?
      Periods::MONTH
    elsif Periods::PERIODS.include?(params[:period])
      params[:period]
    else
      raise InvalidQueryParamError
    end
  end

  def country_code_from_params
    if params[:country_code].blank?
      ServerStat::ALL
    elsif ServerStat::COUNTRY_CODES.include?(params[:country_code])
      params[:country_code]
    else
      raise InvalidQueryParamError
    end
  end

  def server_from_params
    Server.find(params[:id])
  end
end
