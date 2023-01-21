# frozen_string_literal: true

class ShortUuid
  def self.from_uuid(uuid)
    Base58Id.uuid_to_base58(uuid)
  end

  def self.to_uuid(short_uuid)
    Base58Id.base58_to_uuid(short_uuid)
  end

  def self.valid?(short_uuid)
    if short_uuid.blank?
      false
    else
      Base58Id.valid_base58?(short_uuid)
    end
  end
end
