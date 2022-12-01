# frozen_string_literal: true

class PrefixedPublicId
  PREFIX_MAP = {
    Server     => 'server',
    ServerVote => 'server_vote',
    User       => 'user',
  }.freeze
  INVERTED_PREFIX_MAP = PREFIX_MAP.invert

  def self.generate(record)
    prefix = PREFIX_MAP.fetch(record.class)
    public_id = PublicId.from_uuid(record.uuid)

    "#{prefix}_#{public_id}"
  end

  def self.parse(string)
    prefix, _separator, public_id = string.rpartition('_')

    record_class = INVERTED_PREFIX_MAP.fetch(prefix)
    uuid = PublicId.to_uuid(public_id)

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
