# frozen_string_literal: true

class ServerBannerImageCacheStoreCleanUpJob < ApplicationJob
  # TODO: rewrite lock: :while_executing)

  def perform
    ServerBannerImage.build_cache_store.cleanup
  end
end
