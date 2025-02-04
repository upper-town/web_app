# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::PublishEventJob do
  describe '#perform' do
    context 'when PublishEvent result is a success' do
      it 'does not enqueue any other job' do
        allow(ServerWebhooks::PublishEvent).to receive(:call).and_return(Result.success)
        server_webhook_event = create(:server_webhook_event)

        described_class.new.perform(server_webhook_event)

        expect(described_class).not_to have_been_enqueued

        expect(ServerWebhooks::PublishEvent).to have_received(:call).with(server_webhook_event)
      end
    end

    context 'when PublishEvent result is a failure' do
      context 'when result does not have a retry_in' do
        it 'does not reenqueue job to publish the event later' do
          allow(ServerWebhooks::PublishEvent).to receive(:call).and_return(Result.failure)
          server_webhook_event = create(:server_webhook_event)

          described_class.new.perform(server_webhook_event)

          expect(described_class).not_to have_been_enqueued

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

            described_class.new.perform(server_webhook_event)

            expect(described_class)
              .to have_been_enqueued
              .with(server_webhook_event)
              .at(120.seconds.from_now)

            expect(ServerWebhooks::PublishEvent).to have_received(:call).with(server_webhook_event)
          end
        end
      end
    end
  end
end
