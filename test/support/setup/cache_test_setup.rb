# frozen_string_literal: true

module CacheTestSetup
  def setup
    super

    Rails.cache.clear
  end
end
