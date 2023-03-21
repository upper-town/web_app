# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::CreateEventJob do
  describe '#perform' do
    context 'when a Server cannot be found with server_id' do
      it 'raises an error' do
        expect do
          described_class.new.perform(0, 'test.event_type', nil)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when server does not have ServerWebhookConfig for event_type' do
      it 'does not create event and does not schedule job to publish it' do
        server = create(:server)
        create(:server_webhook_config, server: server, event_type: 'test.event_type', disabled_at: Time.current)

        server_webhooks_create_event = instance_double(ServerWebhooks::CreateEvent)
        allow(ServerWebhooks::CreateEvent).to receive(:new).and_return(server_webhooks_create_event)
        allow(server_webhooks_create_event).to receive(:call)
        publish_event_job_size_before = ServerWebhooks::PublishEventJob.jobs.size

        described_class.new.perform(server.id, 'test.event_type', 1)

        publish_event_job_size_after = ServerWebhooks::PublishEventJob.jobs.size
        expect(ServerWebhooks::CreateEvent).not_to have_received(:new)
        expect(server_webhooks_create_event).not_to have_received(:call)
        expect(publish_event_job_size_after).to eq(publish_event_job_size_before)
      end
    end

    context 'when server has ServerWebhookConfig for event_type' do
      it 'creates event and schedules job to publish it' do
        server = create(:server)
        create(:server_webhook_config, server: server, event_type: 'test.event_type', disabled_at: nil)
        server_webhook_event = create(:server_webhook_event)

        server_webhooks_create_event = instance_double(ServerWebhooks::CreateEvent)
        allow(ServerWebhooks::CreateEvent).to receive(:new).and_return(server_webhooks_create_event)
        allow(server_webhooks_create_event).to receive(:call).and_return(server_webhook_event)
        publish_event_job_size_before = ServerWebhooks::PublishEventJob.jobs.size

        described_class.new.perform(server.id, 'test.event_type', 1)

        publish_event_job_size_after = ServerWebhooks::PublishEventJob.jobs.size
        last_publish_event_job = ServerWebhooks::PublishEventJob.jobs.last
        expect(ServerWebhooks::CreateEvent)
          .to have_received(:new)
          .with(server, 'test.event_type', 1)
          .once
        expect(server_webhooks_create_event).to have_received(:call).once
        expect(publish_event_job_size_after).to eq(publish_event_job_size_before + 1)
        expect(last_publish_event_job['args']).to eq([server_webhook_event.id])
      end
    end
  end
end
