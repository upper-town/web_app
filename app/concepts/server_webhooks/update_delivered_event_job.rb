# frozen_string_literal: true

module ServerWebhooks
  class UpdateDeliveredEventJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(server_webhook_event_id)
      server_webhook_event = ServerWebhookEvent.find(server_webhook_event_id)

      server_webhook_event.notice = ''
      server_webhook_event.status = ServerWebhookEvent::DELIVERED
      server_webhook_event.save!
    end
  end
end
