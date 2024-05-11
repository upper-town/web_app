# frozen_string_literal: true

# == Schema Information
#
# Table name: server_banner_images
#
#  id           :bigint           not null, primary key
#  approved_at  :datetime
#  blob         :binary           not null
#  byte_size    :bigint           not null
#  checksum     :string           not null
#  content_type :string           not null
#  metadata     :jsonb            not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  server_id    :bigint           not null
#
# Indexes
#
#  index_server_banner_images_on_server_id  (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
class ServerBannerImage < ApplicationRecord
  belongs_to :server, inverse_of: :banner_image

  def self.not_approved
    where(approved_at: nil)
  end

  def self.approved
    where.not(approved_at: nil)
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
    disk_cache.delete
    update!(approved_at: nil)
  end

  def disk_cache
    @disk_cache ||= ServerBannerImageDiskCache.new(id)
  end

  def read_from_disk_cache
    if disk_cache.exists?
      self.blob = disk_cache.read
      self.content_type = Marcel::MimeType.for(blob)
      self.byte_size = blob.bytesize
      self.checksum = Digest::SHA256.hexdigest(blob)

      true
    else
      false
    end
  end

  def write_to_disk_cache
    disk_cache.write(blob)
  end
end
