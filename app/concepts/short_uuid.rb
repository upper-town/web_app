# frozen_string_literal: true

class ShortUuid
  MAX_SHORT_UUID_STR_SIZE = 22 # hmep7uZkFTa9zuEuQB3XV5
  MAX_UUID_INTEGER_VALUE = (2**128) - 1 # ffffffff-ffff-ffff-ffff-ffffffffffff

  def self.from_uuid(uuid)
    Base58Id.uuid_to_base58(uuid)
  end

  def self.to_uuid(short_uuid)
    Base58Id.base58_to_uuid(short_uuid)
  end

  def self.valid?(short_uuid)
    return false if short_uuid.blank?
    return false if short_uuid.size > MAX_SHORT_UUID_STR_SIZE
    return false if !Base58Id.valid_base58?(short_uuid)
    return false if Base58Id.base58_to_integer(short_uuid) > MAX_UUID_INTEGER_VALUE

    true
  end
end
