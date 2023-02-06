# frozen_string_literal: true

class ServersController < ApplicationController
  include Pagy::Backend

  def index
    current_time = Time.current

    @app = app_from_params
    @period = period_from_params
    @country_code = country_code_from_params

    @pagy, @servers = pagy(Servers::IndexQuery.new(@app, @period, @country_code, current_time).call)
    @servers.load

    @server_stats_hash = Servers::IndexStatsQuery.new(@servers.ids, @country_code, current_time).call

  rescue Pagy::OverflowError, InvalidQueryParamError
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
      ServerStat::GLOBAL
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
