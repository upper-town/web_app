# frozen_string_literal: true

module Webhooks
  class PublisherJob < ApplicationPollingJob
    limits_concurrency key: "0", on_conflict: :discard

    def perform
      WebhookConfig
        .enabled
        .joins(:events)
        .where(events: { webhook_batch_id: nil })
        .distinct
        .select(:id)
        .in_batches do |webhook_configs|
          jobs = webhook_configs.map { PublishJob.new(it) }
          ActiveJob.perform_all_later(jobs)
        end
    end
  end
end
