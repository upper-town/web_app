# frozen_string_literal: true

module Webhooks
  class PublishJob < ApplicationPollingJob
    def perform(webhook_config)
      webhook_config
        .events
        .unbatched
        .in_batches do |webhook_events|
          ActiveRecord::Base.transaction do
            webhook_batch = WebhookBatch.create!(config: webhook_config, status: WebhookBatch::PENDING)
            webhook_events.update_all(webhook_batch_id: webhook_batch.id)
          end
        end

      webhook_config
        .batches
        .pending
        .select(:id)
        .in_batches do |webhook_batches|
          ActiveRecord::Base.transaction do
            webhook_batch_ids = webhook_batches.pluck(:id)
            WebhookBatch.where(id: webhook_batch_ids).update_all(status: WebhookBatch::QUEUED)

            jobs = webhook_batch_ids.map { PublishBatchJob.new(WebhookBatch.new(id: it)) }
            ActiveJob.perform_all_later(jobs)
          end
        end
    end
  end
end
