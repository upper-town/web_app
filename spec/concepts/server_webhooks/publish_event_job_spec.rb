# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::PublishEventJob do
  describe '#perform' do
    context 'when a ServerWebhookEvent is not found' do
      it 'raises an error' do
        expect do
          described_class.new.perform(0)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when PublishEvent result is a success' do
      it 'does not enqueue any other job' do
        allow(ServerWebhooks::PublishEvent).to receive(:call).and_return(Result.success)
        server_webhook_event = create(:server_webhook_event)

        described_class.new.perform(server_webhook_event.id)

        expect(ServerWebhooks::CheckUpConfigJob).not_to have_enqueued_sidekiq_job
        expect(described_class).not_to have_enqueued_sidekiq_job

        expect(ServerWebhooks::PublishEvent).to have_received(:call).with(server_webhook_event)
      end
    end

    context 'when PublishEvent result is a failure' do
      context 'when result does not have a check_up_config_id' do
        it 'does not enqueue job to perform a check up' do
          allow(ServerWebhooks::PublishEvent).to receive(:call).and_return(Result.failure)
          server_webhook_event = create(:server_webhook_event)

          described_class.new.perform(server_webhook_event.id)

          expect(ServerWebhooks::CheckUpConfigJob).not_to have_enqueued_sidekiq_job

          expect(ServerWebhooks::PublishEvent).to have_received(:call).with(server_webhook_event)
        end
      end

      context 'when result does not have a retry_in' do
        it 'does not reenqueue job to publish the event later' do
          allow(ServerWebhooks::PublishEvent).to receive(:call).and_return(Result.failure)
          server_webhook_event = create(:server_webhook_event)

          described_class.new.perform(server_webhook_event.id)

          expect(described_class).not_to have_enqueued_sidekiq_job

          expect(ServerWebhooks::PublishEvent).to have_received(:call).with(server_webhook_event)
        end
      end

      context 'when result has a check_up_config_id' do
        it 'enqueues job to perform a check up on that ServerWebhookConfig' do
          allow(ServerWebhooks::PublishEvent)
            .to receive(:call)
            .and_return(Result.failure(nil, check_up_config_id: 123456))
          server_webhook_event = create(:server_webhook_event)

          described_class.new.perform(server_webhook_event.id)

          expect(ServerWebhooks::CheckUpConfigJob).to have_enqueued_sidekiq_job(123456)

          expect(ServerWebhooks::PublishEvent).to have_received(:call).with(server_webhook_event)
        end
      end

      context 'when result has a retry_in' do
        it 'reenqueues job to publish the event later' do
          freeze_time do
            allow(ServerWebhooks::PublishEvent)
              .to receive(:call)
              .and_return(Result.failure(nil, retry_in: 120))
            server_webhook_event = create(:server_webhook_event)

            described_class.new.perform(server_webhook_event.id)

            expect(described_class)
              .to have_enqueued_sidekiq_job(server_webhook_event.id)
              .at(120.seconds.from_now)

            expect(ServerWebhooks::PublishEvent).to have_received(:call).with(server_webhook_event)
          end
        end
      end
    end
  end
end
