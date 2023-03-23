# frozen_string_literal: true

module ServerWebhooks
  class CreateEventJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(server_id, event_type, record_id)
      server = Server.find(server_id)
      return unless server.webhook_config?(event_type)

      server_webhook_event = CreateEvent.new(server, event_type, record_id).call
      PublishEventJob.perform_async(server_webhook_event.id)
    end
  end
end
