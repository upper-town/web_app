# frozen_string_literal: true

class PublicId
  def self.from_uuid(uuid)
    Base58Id.uuid_to_base58(uuid)
  end

  def self.to_uuid(public_id)
    Base58Id.base58_to_uuid(public_id)
  end
end
