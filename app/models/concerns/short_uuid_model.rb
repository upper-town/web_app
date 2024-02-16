# frozen_string_literal: true

module ShortUuidModel
  extend ActiveSupport::Concern

  class_methods do
    def find_by_short_uuid(short_uuid)
      find_by(uuid: ShortUuid.to_uuid(short_uuid))
    end

    alias_method :find_by_suuid, :find_by_short_uuid

    def find_by_short_uuid!(short_uuid)
      find_by!(uuid: ShortUuid.to_uuid(short_uuid))
    end

    alias_method :find_by_suuid!, :find_by_short_uuid!

    def where_short_uuid(short_uuid)
      short_uuids = Array(short_uuid)
      uuids = short_uuids.map { |suuid| ShortUuid.to_uuid(suuid) }

      where(uuid: uuids)
    end

    alias_method :where_suuid, :where_short_uuid

    def exists_short_uuid?(short_uuid)
      exists?(uuid: ShortUuid.to_uuid(short_uuid))
    end

    alias_method :exists_suuid?, :exists_short_uuid?
  end

  def short_uuid
    ShortUuid.from_uuid(uuid)
  end

  alias suuid short_uuid
end
