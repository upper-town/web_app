# frozen_string_literal: true

class ScopedShortUuid
  MAP = {
    App         => 'app',
    Server      => 'server',
    UserAccount => 'user_account',
  }

  INVERTED_MAP = MAP.invert

  def self.generate(record)
    scope = MAP.fetch(record.class)
    short_uuid = ShortUuid.from_uuid(record.uuid)

    "#{scope}_#{short_uuid}"
  end

  def self.parse(string)
    scope, _separator, short_uuid = string.rpartition('_')

    record_class = INVERTED_MAP.fetch(scope)
    uuid = ShortUuid.to_uuid(short_uuid)

    [record_class, uuid]
  end

  def self.find_record(string)
    record_class, uuid = parse(string)

    record_class.find_by(uuid: uuid)
  end

  def self.record_exists?(string)
    record_class, uuid = parse(string)

    record_class.exists?(uuid: uuid)
  end
end
