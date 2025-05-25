# frozen_string_literal: true

module CacheTestSetup
  def setup
    Rails.cache.clear

    super
  end
end
