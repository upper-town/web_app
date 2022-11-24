# frozen_string_literal: true

class ShortId
  def self.from_uuid(uuid)
    Base58Id.uuid_to_base58(uuid)
  end

  def self.to_uuid(short_id)
    Base58Id.base58_to_uuid(short_id)
  end
end
