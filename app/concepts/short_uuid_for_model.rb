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

    def find_by_suuid(*args)
      find_by_short_uuid(*args)
    end

    def find_by_suuid!(*args)
      find_by_short_uuid!(*args)
    end
  end
end
