# frozen_string_literal: true

class ServerBannerImage < ApplicationRecord
  CACHE_EXPIRES_IN = 10.minutes

  belongs_to :server, inverse_of: :banner_image

  def self.not_approved
    where(approved_at: nil)
  end

  def self.approved
    where.not(approved_at: nil)
  end

  def self.build_cache_store
    ActiveSupport::Cache::FileStore.new("/tmp/cache/server_banner_images")
  end

  def approved?
    approved_at.present?
  end

  def not_approved?
    !approved?
  end

  def approve!
    update!(approved_at: Time.current)
  end

  def not_approve!
    cache_store.delete(id)
    update!(approved_at: nil)
  end

  def cache_store
    @cache_store ||= ServerBannerImage.build_cache_store
  end

  def read_from_cache
    read_attributes = cache_store.read(id)

    if read_attributes
      assign_attributes(read_attributes)
      true
    else
      false
    end
  end

  def write_to_cache
    cache_store.write(id, attributes, expires_in: CACHE_EXPIRES_IN)
  end
end
