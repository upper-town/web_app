# frozen_string_literal: true

module Webhooks
  class DeleteOldEventsJob < ApplicationJob
    queue_as "low"
    limits_concurrency key: ->(*) { "0" }

    def perform
      old_webhook_events_query.delete_all
    end

    private

    def old_webhook_events_query
      WebhookEvent.where(
        status: [
          WebhookEvent::FAILED,
          WebhookEvent::DELIVERED
        ],
        updated_at: ..(3.months.ago)
      )
    end
  end
end
