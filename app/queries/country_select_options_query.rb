# frozen_string_literal: true

class CountrySelectOptionsQuery
  include Callable

  attr_reader(
    :only_in_use,
    :with_continents,
    :cache_enabled,
    :cache_key,
    :cache_expires_in
  )

  CACHE_KEY = "country_select_options_query"
  CACHE_EXPIRES_IN = 1.minute

  def initialize(
    only_in_use: false,
    with_continents: false,
    cache_enabled: true,
    cache_key: CACHE_KEY,
    cache_expires_in: CACHE_EXPIRES_IN
  )
    @only_in_use = only_in_use
    @with_continents = with_continents
    @cache_enabled = cache_enabled
    @cache_key = "#{cache_key}#{':only_in_use' if only_in_use}"
    @cache_expires_in = cache_expires_in
  end

  def call
    with_cache_if_enabled do
      server_country_codes =
        if only_in_use
          Server.distinct.pluck(:country_code)
        else
          Server::COUNTRY_CODES
        end

      build_country_code_options(server_country_codes)
    end
  end

  private

  def build_country_code_options(country_codes)
    options = []
    countries = country_codes.map { ISO3166::Country.new(it) }

    if with_continents
      countries
        .sort_by { [it.continent, it.common_name] }
        .group_by { it.continent }
        .each do |continent, countries|
          options << build_option_for_continent(continent, countries)
          countries.each { options << build_option_for_country(it) }
        end
    else
      countries
        .sort_by { it.common_name }
        .each { options << build_option_for_country(it) }
    end

    options
  end

  def build_option_for_continent(continent, countries)
    [continent, countries.map { it.alpha2 }.join(","), { class: "fw-bold" }]
  end

  def build_option_for_country(country)
    ["#{country.emoji_flag} #{country.common_name}", country.alpha2]
  end

  def with_cache_if_enabled(&)
    if cache_enabled
      Rails.cache.fetch(cache_key, expires_in: cache_expires_in, &)
    else
      yield
    end
  end
end
