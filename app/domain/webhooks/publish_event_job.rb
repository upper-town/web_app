# frozen_string_literal: true

module Webhooks
  class PublishEventJob < ApplicationJob
    # TODO: rewrite lock: :while_executing)

    def perform(webhook_event)
      result = PublishEvent.call(webhook_event)

      if result.failure?
        Rails.logger.info do
          "[Webhooks::PublishEventJob] failure: #{result.errors.to_hash}"
        end

        if result.retry_in.present?
          PublishEventJob.set(wait: result.retry_in).perform_later(webhook_event)
        end
      end
    end
  end
end
