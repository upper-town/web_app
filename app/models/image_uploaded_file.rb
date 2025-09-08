# frozen_string_literal: true

class ImageUploadedFile < ApplicationModel
  CONTENT_TYPES = ["image/png", "image/jpeg"]
  MAX_BYTE_SIZE = 512 * 1024

  attribute :uploaded_file

  validate :validate_byte_size
  validate :validate_content_type

  delegate :present?, :blank?, :presence, to: :uploaded_file

  def blob
    @blob ||= uploaded_file&.read
  end

  def byte_size
    blob&.size
  end

  def content_type
    Marcel::MimeType.for(blob) if blob
  end

  def checksum
    Digest::SHA256.hexdigest(blob) if blob
  end

  private

  def validate_byte_size
    if uploaded_file && uploaded_file.size > MAX_BYTE_SIZE
      errors.add(:byte_size, :invalid, max_byte_size: number_to_human_size(MAX_BYTE_SIZE))
    end
  end

  def validate_content_type
    if uploaded_file && CONTENT_TYPES.exclude?(content_type)
      errors.add(:content_type, :invalid, allowed_content_types: CONTENT_TYPES.join(", "))
    end
  end
end
