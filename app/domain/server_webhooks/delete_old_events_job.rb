# frozen_string_literal: true

module ServerWebhooks
  class DeleteOldEventsJob < ApplicationJob
    queue_as "low"
    # TODO: rewrite lock: :while_executing)

    def perform
      old_server_webhook_events_query.delete_all
    end

    private

    def old_server_webhook_events_query
      ServerWebhookEvent.where(
        status: [
          ServerWebhookEvent::FAILED,
          ServerWebhookEvent::DELIVERED
        ],
        updated_at: ..(3.months.ago)
      )
    end
  end
end
