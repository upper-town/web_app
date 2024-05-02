# frozen_string_literal: true

class ServerBannerImageUploadedFile < ApplicationModel
  CONTENT_TYPES = ['image/png', 'image/jpeg']
  MAX_BYTE_SIZE = 512 * 1024

  attribute :uploaded_file

  validate :validate_content_type
  validate :validate_byte_size

  def present?
    uploaded_file.present?
  end

  def content_type
    Marcel::MimeType.for(blob) if blob
  end

  def blob
    @blob ||= uploaded_file&.read
  end

  def byte_size
    blob&.size
  end

  def checksum
    Digest::SHA256.hexdigest(blob) if blob
  end

  def validate_content_type
    return unless uploaded_file

    unless CONTENT_TYPES.include?(uploaded_file.content_type)
      errors.add(
        :uploaded_file,
        "Invalid content type. Allowed types: #{CONTENT_TYPES.join(', ')} "
      )
    end
  end

  def validate_byte_size
    return unless uploaded_file

    if uploaded_file.size > MAX_BYTE_SIZE
      errors.add(
        :uploaded_file,
        "File size is too large. Maximum allowed size: #{number_to_human_size(MAX_BYTE_SIZE)}"
      )
    end
  end
end
