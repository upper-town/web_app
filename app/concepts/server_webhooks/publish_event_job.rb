# frozen_string_literal: true

module ServerWebhooks
  class PublishEventJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(server_webhook_event_id)
      server_webhook_event = ServerWebhookEvent.find(server_webhook_event_id)

      result = PublishEvent.new(server_webhook_event).call

      if result.failure?
        Rails.logger.info "[ServerWebhooks::PublishEventJob] #{result.errors.to_hash}"

        if result.data[:check_up_enabled_config_id].present?
          CheckUpEnabledConfigJob.perform_async(result.data[:check_up_enabled_config_id])
        end

        if result.data[:retry_in].present?
          PublishEventJob.perform_in(result.data[:retry_in], server_webhook_event.id)
        end
      end
    end
  end
end
