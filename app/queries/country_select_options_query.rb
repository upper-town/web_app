# frozen_string_literal: true

class CountrySelectOptionsQuery
  include Callable

  attr_reader :only_in_use, :cache_enabled, :cache_key, :cache_expires_in

  CACHE_KEY = "country_select_options_query"
  CACHE_EXPIRES_IN = 5.minutes

  def initialize(only_in_use: false, cache_enabled: true, cache_key: CACHE_KEY, cache_expires_in: CACHE_EXPIRES_IN)
    @only_in_use = only_in_use
    @cache_enabled = cache_enabled
    @cache_key = "#{cache_key}#{only_in_use ? ':only_in_use' : ''}"
    @cache_expires_in = cache_expires_in
  end

  def call
    country_code_options
  end

  def popular_options
    country_code_options.first
  end

  def other_options
    country_code_options.second
  end

  private

  def country_code_options
    with_cache_if_enabled do
      server_country_codes = server_country_codes_query
      popular_country_codes = server_country_codes.shift(10)

      other_country_codes =
        if only_in_use
          server_country_codes.sort
        else
          (Server::COUNTRY_CODES - popular_country_codes).sort
        end

      [
        build_country_code_options(popular_country_codes),
        build_country_code_options(other_country_codes)
      ]
    end
  end

  def server_country_codes_query
    Server
      .group(:country_code)
      .count
      .sort_by { |country_code, count| [-count, country_code] }
      .map { |country_code, _count| country_code }
  end

  def build_country_code_options(country_codes)
    country_codes.map do |country_code|
      country = ISO3166::Country.new(country_code)

      ["#{country.emoji_flag} #{country.common_name}", country_code]
    end
  end

  def with_cache_if_enabled(&)
    if cache_enabled
      Rails.cache.fetch(cache_key, expires_in: cache_expires_in, &)
    else
      yield
    end
  end
end
