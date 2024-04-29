# frozen_string_literal: true

class ServersController < ApplicationController
  def index
    current_time = Time.current

    @app = app_from_params
    @period = period_from_params
    @country_code = country_code_from_params

    @selected_value_app_id = @app ? @app.id : nil
    @selected_value_period = @period
    @selected_value_country_code = @country_code

    @pagination = Pagination.new(
      Servers::IndexQuery.new(@app, @period, @country_code, current_time).call,
      request,
      options: { per_page: 20 }
    )

    @servers = @pagination.results
    @server_stats_hash = Servers::IndexStatsQuery.new(@servers.pluck(:id), @country_code, current_time).call

    status = @pagination.page > 1 && @servers.empty? ? :not_found : :ok

    render(status: status)

  rescue InvalidQueryParamError
    @servers = []
    @server_stats_hash = {}

    render(status: :not_found)
  end

  def show
    @server = server_from_params
  end

  private

  def app_from_params
    if params[:app_id].blank?
      nil
    elsif (app = App.find_by(id: params[:app_id]))
      app
    else
      raise InvalidQueryParamError
    end
  end

  def period_from_params
    if params[:period].blank?
      ServerStat::MONTH
    elsif ServerStat::PERIODS.include?(params[:period])
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
