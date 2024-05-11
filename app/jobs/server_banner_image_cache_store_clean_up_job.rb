# frozen_string_literal: true

class ServerBannerImageCacheStoreCleanUpJob
  include Sidekiq::Job

  sidekiq_options(lock: :while_executing)

  def perform
    ServerBannerImage.build_cache_store.cleanup
  end
end
