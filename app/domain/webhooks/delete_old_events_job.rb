# frozen_string_literal: true

module Webhooks
  class DeleteOldEventsJob < ApplicationJob
    queue_as "low"

    def perform
      WebhookBatch.where(
        status: [WebhookBatch::FAILED, WebhookBatch::DELIVERED],
        updated_at: ..(3.months.ago)
      ).destroy_all
    end
  end
end
