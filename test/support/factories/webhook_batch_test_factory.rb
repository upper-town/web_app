# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:webhook_batch, WebhookBatch,
  config: -> { build_webhook_config },
  status: -> { WebhookBatch::STATUSES.sample }
)
