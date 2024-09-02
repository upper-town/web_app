# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::UpdateDeliveredEventJob do
  describe '#perform' do
    context 'when a ServerWebhookEvent is not found' do
      it 'raises an error' do
        expect do
          described_class.new.perform(0)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a ServerWebhookEvent is found' do
      it 'updates its notice and status' do
        server_webhook_event = create(
          :server_webhook_event,
          notice: 'Some previous notice',
          status: ServerWebhookEvent::RETRY
        )

        described_class.new.perform(server_webhook_event.id)

        server_webhook_event.reload
        expect(server_webhook_event.notice).to eq('')
        expect(server_webhook_event.status).to eq(ServerWebhookEvent::DELIVERED)
      end
    end
  end
end
