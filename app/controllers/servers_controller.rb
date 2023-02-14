# frozen_string_literal: true

class ServersController < ApplicationController
  include Pagy::Backend

  DEFAULT_APP_OPTION = ['All', nil].freeze
  DEFAULT_COUNTRY_CODE_OPTION = ["#{ServerStat::GLOBAL_EMOJI_FLAG} Global", ServerStat::GLOBAL].freeze

  def index
    current_time = Time.current

    @app_options = build_app_options
    @period_options = build_period_options
    @country_code_options = build_country_code_options

    @default_app_option = DEFAULT_APP_OPTION
    @default_country_code_option = DEFAULT_COUNTRY_CODE_OPTION

    @app = app_from_params
    @period = period_from_params
    @country_code = country_code_from_params

    @selected_value_for_app_id = @app.nil? ? DEFAULT_APP_OPTION[1] : @app.suuid
    @selected_value_for_period = @period
    @selected_value_for_country_code = @country_code

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

  def build_app_options
    app_options_by_kind = App::KIND_OPTIONS.each_with_object({}) do |(kind_name, kind), hash|
      hash[kind_name] = apps_query(kind)
    end

    app_options_by_kind.compact_blank
  end

  def build_period_options
    { 'Period' => ServerStat::PERIOD_OPTIONS }
  end

  def build_country_code_options
    most_common_country_codes, rest_country_codes = most_common_country_codes_query(3)

    most_common_options = most_common_country_codes.map { |cc| build_country_code_option(cc) }
    more_options = rest_country_codes.sort.map { |cc| build_country_code_option(cc) }

    {
      'Country' => most_common_options + more_options,
    }.compact_blank
  end

  def build_country_code_option(country_code)
    country = ISO3166::Country.new(country_code)

    ["#{country.emoji_flag} #{country.common_name}", country_code]
  end

  def apps_query(kind)
    App
      .where(kind: kind)
      .select(:name, :uuid)
      .sort_by(&:name)
      .map { |app| [app.name, app.suuid] }
  end

  def most_common_country_codes_query(n)
    sorted_country_codes =
      Server
      .group(:country_code)
      .count
      .sort_by { |_country_code, count| count }
      .reverse
      .map { |country_code, _count| country_code }

    most_common_country_codes = sorted_country_codes.shift(n)
    rest_country_codes = sorted_country_codes

    [most_common_country_codes, rest_country_codes]
  end
end
