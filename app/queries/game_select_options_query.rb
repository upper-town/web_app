# frozen_string_literal: true

class GameSelectOptionsQuery
  include Callable

  CACHE_KEY = "game_select_options_query"
  CACHE_EXPIRES_IN = 5.minutes

  attr_reader(
    :only_in_use,
    :cache_enabled,
    :cache_key,
    :cache_expires_in
  )

  def initialize(only_in_use: false, cache_enabled: true, cache_key: CACHE_KEY, cache_expires_in: CACHE_EXPIRES_IN)
    @only_in_use = only_in_use
    @cache_enabled = cache_enabled
    @cache_key = "#{cache_key}#{only_in_use ? ':only_in_use' : ''}"
    @cache_expires_in = cache_expires_in
  end

  def call
    with_cache_if_enabled do
      game_query
    end
  end

  private

  def game_query
    scope = only_in_use ? Game.joins(:servers) : Game.all

    scope
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
