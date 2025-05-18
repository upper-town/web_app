# frozen_string_literal: true

module ServerWebhooks
  class UpdateDeliveredEventJob < ApplicationJob
    # TODO: rewrite lock: :while_executing)

    def perform(server_webhook_event)
      server_webhook_event.update!(
        notice: "",
        status: ServerWebhookEvent::DELIVERED
      )
    end
  end
end
