# frozen_string_literal: true

module ShortUuidForModel
  def short_uuid
    ShortUuid.from_uuid(uuid)
  end

  def suuid
    short_uuid
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def find_by_short_uuid(short_uuid)
      find_by(uuid: ShortUuid.to_uuid(short_uuid))
    end

    def find_by_short_uuid!(short_uuid)
      find_by!(uuid: ShortUuid.to_uuid(short_uuid))
    end

    def where_short_uuid(short_uuid)
      short_uuids = Array(short_uuid)
      uuids = short_uuids.map { |suuid| ShortUuid.to_uuid(suuid) }

      where(uuid: uuids)
    end

    def exists_short_uuid?(short_uuid)
      exists?(uuid: ShortUuid.to_uuid(short_uuid))
    end

    # Aliases

    def find_by_suuid(*args)
      find_by_short_uuid(*args)
    end

    def find_by_suuid!(*args)
      find_by_short_uuid!(*args)
    end

    def where_suuid(*args)
      where_short_uuid(*args)
    end

    def exists_suuid?(*args)
      exists_short_uuid?(*args)
    end
  end
end
