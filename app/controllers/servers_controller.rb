# frozen_string_literal: true

class ServersController < ApplicationController
  include Pagy::Backend

  class InvalidQueryParam < StandardError; end

  def index
    current_time = Time.current

    @app = app_from_params
    @period = period_from_params
    @country_code = country_code_from_params

    @pagy, @servers = pagy(Servers::IndexQuery.new(@app, @period, @country_code, current_time).call)
    @servers.load

    @server_stats_hash = Servers::IndexStatsQuery.new(@servers.ids, @country_code, current_time).call

  rescue Pagy::OverflowError, InvalidQueryParam
    @servers = []
    @server_stats_hash = {}

    render(status: :not_found)
  end

  private

  def app_from_params
    if params['app_id'].blank? || !ShortUuid.valid?(params['app_id'])
      nil
    elsif (app = App.find_by(uuid: ShortUuid.to_uuid(params['app_id'])))
      app
    else
      raise InvalidQueryParam
    end
  end

  def period_from_params
    if params['period'].blank?
      ServerStat::YEAR
    elsif ServerStat::PERIODS.include?(params['period'])
      params['period']
    else
      raise InvalidQueryParam
    end
  end

  def country_code_from_params
    if params['country_code'].blank?
      ServerStat::GLOBAL
    elsif ServerStat::COUNTRY_CODES.include?(params['country_code'])
      params['country_code']
    else
      raise InvalidQueryParam
    end
  end
end
