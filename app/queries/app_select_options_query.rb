# frozen_string_literal: true

class AppSelectOptionsQuery
  attr_reader :only_in_use, :cache_enabled, :cache_key, :cache_expires_in

  CACHE_KEY = 'app_select_options_query'
  CACHE_EXPIRES_IN = 10.minutes

  def initialize(only_in_use: false, cache_enabled: true, cache_key: CACHE_KEY, cache_expires_in: CACHE_EXPIRES_IN)
    @only_in_use = only_in_use
    @cache_enabled = cache_enabled
    @cache_key = "#{cache_key}#{only_in_use ? ':only_in_use' : ''}"
    @cache_expires_in = cache_expires_in
  end

  def call
    with_cache_if_enabled do
      options_by_type = App::TYPE_OPTIONS.each_with_object({}) do |(type_name, type), hash|
        hash[type_name] = app_query(type)
      end

      options_by_type.compact_blank
    end
  end

  private

  def app_query(type)
    scope = only_in_use ? App.joins(:servers) : App.all

    scope
      .where(type: type)
      .order(name: :asc)
      .distinct
      .pluck(:name, :id)
  end

  def with_cache_if_enabled(&)
    if cache_enabled
      Rails.cache.fetch(cache_key, expires_in: cache_expires_in, &)
    else
      yield
    end
  end
end
