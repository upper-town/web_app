# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::CreateEvents::ServerVoteCreatedJob do
  describe '#perform' do
    context 'when server does not have enabled configs that subscribe to the event_type' do
      it 'does not create ServerWebhookEvent records and does not publish' do
        server = create(:server, country_code: 'US')
        _server_webhook_config1 = create(:server_webhook_config, server: server, event_types: ['server_vote.created'], disabled_at: Time.current)
        _server_webhook_config2 = create(:server_webhook_config, server: server, event_types: ['test.event'], disabled_at: nil)
        account = create(:account)
        server_vote = create(
          :server_vote,
          game: server.game,
          server: server,
          country_code: server.country_code,
          reference: 'anything123456',
          remote_ip: '1.1.1.1',
          account: account,
          created_at: Time.iso8601('2024-09-02T12:00:01Z')
        )

        expect do
          described_class.new.perform(server_vote)
        end.not_to change(ServerWebhookEvent, :count)

        expect(ServerWebhooks::PublishEventJob).not_to have_been_enqueued
      end
    end

    context 'when server has enabled configs that subscribe to the event_type' do
      it 'creates ServerWebhookEvent for them and publishes events' do
        server = create(:server, country_code: 'US')
        server_webhook_config1 = create(:server_webhook_config, server: server, event_types: ['server_vote.created'], disabled_at: nil)
        server_webhook_config2 = create(:server_webhook_config, server: server, event_types: ['server_vote.*'], disabled_at: nil)
        _server_webhook_config3 = create(:server_webhook_config, server: server, event_types: ['test.event'], disabled_at: nil)
        account = create(:account)
        server_vote = create(
          :server_vote,
          game: server.game,
          server: server,
          country_code: server.country_code,
          reference: 'anything123456',
          remote_ip: '1.1.1.1',
          account: account,
          created_at: Time.iso8601('2024-09-02T12:00:01Z')
        )

        expect do
          described_class.new.perform(server_vote)
        end.to change(ServerWebhookEvent, :count).by(2)

        server_webhook_event1 = ServerWebhookEvent.find_by!(config: server_webhook_config1)
        server_webhook_event2 = ServerWebhookEvent.find_by!(config: server_webhook_config2)
        expected_payload = {
          'server_vote' => {
            'uuid'         => server_vote.uuid,
            'game_id'      => server.game_id,
            'server_id'    => server.id,
            'country_code' => 'US',
            'reference'    => 'anything123456',
            'remote_ip'    => '1.1.1.1',
            'account_uuid' => account.uuid,
            'created_at'   => '2024-09-02T12:00:01Z',
          }
        }
        expect(server_webhook_event1.type).to eq('server_vote.created')
        expect(server_webhook_event1.payload).to eq(expected_payload)
        expect(server_webhook_event1.status).to eq('pending')
        expect(server_webhook_event1.server_id).to eq(server_vote.server_id)

        expect(server_webhook_event2.type).to eq('server_vote.created')
        expect(server_webhook_event2.payload).to eq(expected_payload)
        expect(server_webhook_event2.status).to eq('pending')
        expect(server_webhook_event2.server_id).to eq(server_vote.server_id)

        expect(ServerWebhooks::PublishEventJob).to have_been_enqueued.with(server_webhook_event1)
        expect(ServerWebhooks::PublishEventJob).to have_been_enqueued.with(server_webhook_event2)
      end

      context 'when an error is raised during creation of ServerWebhookEvent' do
        it 'raises the error and rolls back' do
          server = create(:server, country_code: 'US')
          _server_webhook_config1 = create(:server_webhook_config, server: server, event_types: ['server_vote.created'], disabled_at: nil)
          _server_webhook_config2 = create(:server_webhook_config, server: server, event_types: ['server_vote.*'], disabled_at: nil)
          _server_webhook_config3 = create(:server_webhook_config, server: server, event_types: ['test.event'], disabled_at: nil)
          account = create(:account)
          server_vote = create(
            :server_vote,
            game: server.game,
            server: server,
            country_code: server.country_code,
            reference: 'anything123456',
            remote_ip: '1.1.1.1',
            account: account,
            created_at: Time.iso8601('2024-09-02T12:00:01Z')
          )
          allow(ServerWebhookEvent).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError)

          expect do
            described_class.new.perform(server_vote)
          end.to(
            raise_error(ActiveRecord::ActiveRecordError).and(
              change(ServerWebhookEvent, :count).by(0)
            )
          )
          expect(ServerWebhookEvent).to have_received(:create!)

          expect(ServerWebhooks::PublishEventJob).not_to have_been_enqueued
        end
      end
    end
  end
end
