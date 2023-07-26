# frozen_string_literal: true

class ServersController < ApplicationController
  def index
    current_time = Time.current
    form_options_query = FormOptionsQuery.new(
      cache_enabled: true,
      cache_options: {
        key_prefix: 'servers_index',
        expires_in: 5.minutes
      }
    )

    @app_id_options = form_options_query.build_app_id_options
    @period_options = form_options_query.build_period_options
    @country_code_options = form_options_query.build_country_code_options

    @default_app_id_option = FormOptionsQuery::OPTION_APP_ID_ALL
    @default_country_code_option = FormOptionsQuery::OPTION_COUNTRY_CODE_ALL

    @app = app_from_params
    @period = period_from_params
    @country_code = country_code_from_params

    @selected_value_for_app_id = @app ? @app.suuid : nil
    @selected_value_for_period = @period
    @selected_value_for_country_code = @country_code

    @pagination = Pagination.new(
      Servers::IndexQuery.new(@app, @period, @country_code, current_time).call,
      request
    )

    @servers = @pagination.results
    @server_stats_hash = Servers::IndexStatsQuery.new(@servers.pluck(:id), @country_code, current_time).call

    render(status: @servers.empty? ? :not_found : :ok)

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
    if params['app_id'].blank? || !ShortUuid.valid?(params['app_id'])
      nil
    elsif (app = App.find_by_suuid(params['app_id']))
      app
    else
      raise InvalidQueryParamError
    end
  end

  def period_from_params
    if params['period'].blank?
      ServerStat::MONTH
    elsif ServerStat::PERIODS.include?(params['period'])
      params['period']
    else
      raise InvalidQueryParamError
    end
  end

  def country_code_from_params
    if params['country_code'].blank?
      ServerStat::ALL
    elsif ServerStat::COUNTRY_CODES.include?(params['country_code'])
      params['country_code']
    else
      raise InvalidQueryParamError
    end
  end

  def server_from_params
    Server.find_by_suuid!(params['suuid'])
  end
end
