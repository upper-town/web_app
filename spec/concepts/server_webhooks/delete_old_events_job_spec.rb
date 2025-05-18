require 'rails_helper'

RSpec.describe ServerWebhooks::DeleteOldEventsJob do
  describe '#perform' do
    it 'deletes events in final statuses that have not been updated in the last 3 months' do
      travel_to('2023-06-01T12:50:10Z') do
        pending_event_1 = create(:server_webhook_event, status: ServerWebhookEvent::PENDING, updated_at: '2023-05-01')
        pending_event_2 = create(:server_webhook_event, status: ServerWebhookEvent::PENDING, updated_at: '2023-01-01')

        retry_event_1 = create(:server_webhook_event, status: ServerWebhookEvent::RETRY, updated_at: '2023-05-01')
        retry_event_2 = create(:server_webhook_event, status: ServerWebhookEvent::RETRY, updated_at: '2023-01-01')

        failed_event_1 = create(:server_webhook_event, status: ServerWebhookEvent::FAILED, updated_at: '2023-05-01')
        failed_event_2 = create(:server_webhook_event, status: ServerWebhookEvent::FAILED, updated_at: '2023-03-01T12:50:11')
        _failed_event_3 = create(:server_webhook_event, status: ServerWebhookEvent::FAILED, updated_at: '2023-03-01T12:50:10')
        _failed_event_4 = create(:server_webhook_event, status: ServerWebhookEvent::FAILED, updated_at: '2023-01-01')

        delivered_event_1 = create(:server_webhook_event, status: ServerWebhookEvent::DELIVERED, updated_at: '2023-05-01')
        delivered_event_2 = create(:server_webhook_event, status: ServerWebhookEvent::DELIVERED, updated_at: '2023-03-01T12:50:11')
        _delivered_event_3 = create(:server_webhook_event, status: ServerWebhookEvent::DELIVERED, updated_at: '2023-03-01T12:50:10')
        _delivered_event_4 = create(:server_webhook_event, status: ServerWebhookEvent::DELIVERED, updated_at: '2023-01-01')

        described_class.new.perform

        expect(ServerWebhookEvent.all).to contain_exactly(
          pending_event_1,
          pending_event_2,
          retry_event_1,
          retry_event_2,
          failed_event_1,
          failed_event_2,
          delivered_event_1,
          delivered_event_2
        )
      end
    end
  end
end
