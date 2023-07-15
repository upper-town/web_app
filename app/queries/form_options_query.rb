# frozen_string_literal: true

class FormOptionsQuery
  DEFAULT_CACHE_OPTIONS = {
    key_prefix: 'form_options_query',
    expires_in: 1.minute
  }.freeze

  DEFAULT_APP_ID_OPTION = ['All', nil].freeze
  DEFAULT_COUNTRY_CODE_OPTION = ["#{ServerStat::GLOBAL_EMOJI_FLAG} Global", ServerStat::GLOBAL].freeze

  def initialize(cache_enabled: false, cache_options: {})
    @cache_enabled = cache_enabled
    @cache_options = DEFAULT_CACHE_OPTIONS.merge(cache_options)
  end

  def build_app_id_options
    fetch_cache_if_enabled('app_id_options') do
      app_id_options_by_type = App::TYPE_OPTIONS.each_with_object({}) do |(type_name, type), hash|
        hash[type_name] = apps_query(type)
      end

      app_id_options_by_type.compact_blank
    end
  end

  def build_period_options
    { 'Period' => ServerStat::PERIOD_OPTIONS }
  end

  def build_country_code_options
    fetch_cache_if_enabled('country_code_options') do
      most_common_country_codes, rest_country_codes = most_common_country_codes_query(3)

      most_common_options = most_common_country_codes.map { |cc| build_country_code_option(cc) }
      more_options = rest_country_codes.sort.map { |cc| build_country_code_option(cc) }

      {
        'Country' => most_common_options + more_options,
      }.compact_blank
    end
  end

  private

  def fetch_cache_if_enabled(key_suffix, &block)
    if @cache_enabled
      key = "#{@cache_options[:key_prefix]}:#{key_suffix}"
      expires_in = @cache_options[:expires_in]

      Rails.cache.fetch(key, expires_in: expires_in, &block)
    else
      block.call
    end
  end

  def apps_query(type)
    App
      .where(type: type)
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

  def build_country_code_option(country_code)
    country = ISO3166::Country.new(country_code)

    ["#{country.emoji_flag} #{country.common_name}", country_code]
  end
end
