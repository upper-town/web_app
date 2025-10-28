# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:webhook_event, WebhookEvent,
  config: -> { build_webhook_config },
  uuid: -> { SecureRandom.uuid },
  type: -> { WebhookEvent::TYPES.sample },
  data: -> { "{}" }
)
