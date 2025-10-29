# frozen_string_literal: true

module Webhooks
  class CreateEvents
    include Callable

    DATA_BUILDER = {
      WebhookEvent::SERVER_VOTE_CREATED => Data::ServerVoteCreated,
    }

    attr_reader :source, :type, :data_args, :uuid

    def initialize(source, type, *data_args, uuid: nil)
      @source = source
      @type = type
      @data_args = data_args
      @uuid = uuid || SecureRandom.uuid_v7
    end

    def call
      webhook_configs = WebhookConfig.for(source, type)
      return if webhook_configs.empty?

      data = build_data

      webhook_event_hashes = webhook_configs.map do |webhook_config|
        {
          webhook_config_id: webhook_config.id,
          webhook_batch_id: nil,
          type:,
          uuid:,
          data:
        }
      end
      WebhookEvent.insert_all(webhook_event_hashes, unique_by: [:webhook_config_id, :uuid])
    end

    private

    def build_data
      raise "#{self.class.name}: unknown type: #{type}" unless DATA_BUILDER.key?(type)

      DATA_BUILDER[type].call(*data_args)
    end
  end
end
