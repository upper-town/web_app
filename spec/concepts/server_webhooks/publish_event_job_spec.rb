# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::PublishEventJob do
  describe '#perform' do
    context 'when a ServerWebhookEvent cannot be found with server_webhook_event_id' do
      it 'raises an error' do
        expect do
          described_class.new.perform(0)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when PublishEvent result is a success' do
      it 'does not schedule any other job' do
        publish_event = instance_double(ServerWebhooks::PublishEvent)
        result = Result.success
        allow(ServerWebhooks::PublishEvent).to receive(:new).and_return(publish_event)
        allow(publish_event).to receive(:call).and_return(result)

        server_webhook_event = create(:server_webhook_event)

        check_up_enabled_config_job_size_before = ServerWebhooks::CheckUpEnabledConfigJob.jobs.size
        publish_event_job_size_before = described_class.jobs.size

        described_class.new.perform(server_webhook_event.id)

        check_up_enabled_config_job_size_after = ServerWebhooks::CheckUpEnabledConfigJob.jobs.size
        publish_event_job_size_after = described_class.jobs.size

        expect(check_up_enabled_config_job_size_after).to eq(check_up_enabled_config_job_size_before)
        expect(publish_event_job_size_after).to eq(publish_event_job_size_before)
        expect(ServerWebhooks::PublishEvent).to have_received(:new).with(server_webhook_event).once
        expect(publish_event).to have_received(:call).once
      end
    end

    context 'when PublishEvent result is a failure' do
      context 'when result does not have a server_webhook_config_id' do
        it 'does not schedule job to perform a check up' do
          publish_event = instance_double(ServerWebhooks::PublishEvent)
          result = Result.failure
          allow(ServerWebhooks::PublishEvent).to receive(:new).and_return(publish_event)
          allow(publish_event).to receive(:call).and_return(result)

          server_webhook_event = create(:server_webhook_event)
          check_up_enabled_config_job_size_before = ServerWebhooks::CheckUpEnabledConfigJob.jobs.size

          described_class.new.perform(server_webhook_event.id)

          check_up_enabled_config_job_size_after = ServerWebhooks::CheckUpEnabledConfigJob.jobs.size
          expect(check_up_enabled_config_job_size_after).to eq(check_up_enabled_config_job_size_before)
          expect(ServerWebhooks::PublishEvent).to have_received(:new).with(server_webhook_event).once
          expect(publish_event).to have_received(:call).once
        end
      end

      context 'when result does not have a retry_in' do
        it 'does not reschedule job to publish the event later' do
          publish_event = instance_double(ServerWebhooks::PublishEvent)
          result = Result.failure
          allow(ServerWebhooks::PublishEvent).to receive(:new).and_return(publish_event)
          allow(publish_event).to receive(:call).and_return(result)

          server_webhook_event = create(:server_webhook_event)
          publish_event_job_size_before = described_class.jobs.size

          described_class.new.perform(server_webhook_event.id)

          publish_event_job_size_after = described_class.jobs.size
          expect(publish_event_job_size_after).to eq(publish_event_job_size_before)
          expect(ServerWebhooks::PublishEvent).to have_received(:new).with(server_webhook_event).once
          expect(publish_event).to have_received(:call).once
        end
      end

      context 'when result has a server_webhook_config_id' do
        it 'schedules job to perform a check up on that ServerWebhookConfig' do
          publish_event = instance_double(ServerWebhooks::PublishEvent)
          result = Result.failure(nil, server_webhook_config_id: 123456)
          allow(ServerWebhooks::PublishEvent).to receive(:new).and_return(publish_event)
          allow(publish_event).to receive(:call).and_return(result)

          server_webhook_event = create(:server_webhook_event)
          check_up_enabled_config_job_size_before = ServerWebhooks::CheckUpEnabledConfigJob.jobs.size

          described_class.new.perform(server_webhook_event.id)

          check_up_enabled_config_job_size_after = ServerWebhooks::CheckUpEnabledConfigJob.jobs.size
          last_check_up_enabled_config_job = ServerWebhooks::CheckUpEnabledConfigJob.jobs.last
          expect(check_up_enabled_config_job_size_after).to eq(check_up_enabled_config_job_size_before + 1)
          expect(last_check_up_enabled_config_job['args']).to eq([123456])
          expect(ServerWebhooks::PublishEvent).to have_received(:new).with(server_webhook_event).once
          expect(publish_event).to have_received(:call).once
        end
      end

      context 'when result has a retry_in' do
        it 'reschedules job to publish the event later' do
          freeze_time

          publish_event = instance_double(ServerWebhooks::PublishEvent)
          result = Result.failure(nil, retry_in: 120)
          allow(ServerWebhooks::PublishEvent).to receive(:new).and_return(publish_event)
          allow(publish_event).to receive(:call).and_return(result)

          server_webhook_event = create(:server_webhook_event)
          publish_event_job_size_before = described_class.jobs.size

          described_class.new.perform(server_webhook_event.id)

          publish_event_job_size_after = described_class.jobs.size
          last_publish_event_job = described_class.jobs.last
          expect(publish_event_job_size_after).to eq(publish_event_job_size_before + 1)
          expect(last_publish_event_job['args']).to eq([server_webhook_event.id])
          expect(last_publish_event_job['at']).to eq(120.seconds.from_now.to_i)
          expect(ServerWebhooks::PublishEvent).to have_received(:new).with(server_webhook_event).once
          expect(publish_event).to have_received(:call).once
        end
      end
    end
  end
end
