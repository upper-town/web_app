# frozen_string_literal: true

module Webhooks
  class UpdateDeliveredEventJob < ApplicationJob
    limits_concurrency key: ->(webhook_event) { webhook_event }

    def perform(webhook_event)
      webhook_event.update!(
        metadata: {},
        status: WebhookEvent::DELIVERED
      )
    end
  end
end
