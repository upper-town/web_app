# frozen_string_literal: true

module ShortUuidForModel
  def short_uuid
    ShortUuid.from_uuid(uuid)
  end
  alias suuid short_uuid

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def find_by_short_uuid(short_uuid)
      find_by(uuid: ShortUuid.to_uuid(short_uuid))
    end
    alias find_by_suuid find_by_short_uuid

    def find_by_short_uuid!(short_uuid)
      find_by!(uuid: ShortUuid.to_uuid(short_uuid))
    end
    alias find_by_suuid! find_by_short_uuid!

    def where_short_uuid(short_uuid)
      short_uuids = Array(short_uuid)
      uuids = short_uuids.map { |suuid| ShortUuid.to_uuid(suuid) }

      where(uuid: uuids)
    end
    alias where_suuid where_short_uuid

    def exists_short_uuid?(short_uuid)
      exists?(uuid: ShortUuid.to_uuid(short_uuid))
    end
    alias exists_suuid? exists_short_uuid?
  end
end
