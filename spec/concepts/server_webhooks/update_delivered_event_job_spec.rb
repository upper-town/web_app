# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::UpdateDeliveredEventJob do
  describe '#perform' do
    it 'updates its notice and status' do
      server_webhook_event = create(
        :server_webhook_event,
        notice: 'Some previous notice',
        status: ServerWebhookEvent::RETRY
      )

      described_class.new.perform(server_webhook_event)

      server_webhook_event.reload
      expect(server_webhook_event.notice).to eq('')
      expect(server_webhook_event.status).to eq(ServerWebhookEvent::DELIVERED)
    end
  end
end
