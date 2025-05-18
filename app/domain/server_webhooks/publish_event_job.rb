# frozen_string_literal: true

module ServerWebhooks
  class PublishEventJob < ApplicationJob
    # TODO: rewrite lock: :while_executing)

    def perform(server_webhook_event)
      result = PublishEvent.call(server_webhook_event)

      if result.failure?
        Rails.logger.info do
          "[ServerWebhooks::PublishEventJob] failure: #{result.errors.to_hash}"
        end

        if result.data[:retry_in].present?
          PublishEventJob.set(wait: result.data[:retry_in]).perform_later(server_webhook_event)
        end
      end
    end
  end
end
