# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::CreateEvent do
  describe '#call' do
    context 'when event_type is unknown' do
      it 'raises an error' do
        expect do
          described_class.new(any_args, 'unknown.event_type', nil).call
        end.to raise_error('Unknown event_type for ServerWebhooks::CreateEvent')
      end
    end

    context 'when event_type is server_votes.create' do
      context 'when a ServerVote cannot be found with record_id' do
        it 'raises an error' do
          expect do
            described_class.new(any_args, 'server_votes.create', 0).call
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      describe 'ServerVote without Account' do
        it 'creates a ServerWebhookEvent with ServerVote payload' do
          server = create(:server)
          event_type = 'server_votes.create'
          server_vote = create(
            :server_vote,
            reference:    'user_123456',
            remote_ip:    '8.8.8.8',
            server:       server,
            game:         server.game,
            country_code: 'US',
            account:      nil,
          )

          described_class.new(server, event_type, server_vote.id).call

          server_webhook_event = ServerWebhookEvent.last
          expect(server_webhook_event.server).to eq(server)
          expect(server_webhook_event.type).to eq(event_type)
          expect(server_webhook_event.status).to eq(ServerWebhookEvent::PENDING)
          expect(server_webhook_event.payload).to eq({
            'server_vote' => {
              'id'           => server_vote.id,
              'reference'    => 'user_123456',
              'remote_ip'    => '8.8.8.8',
              'server_id'    => server.id,
              'game_id'      => server.game.id,
              'country_code' => 'US',
              'account_id'   => nil,
              'created_at'   => server_vote.created_at.as_json,
            }
          })
        end
      end

      describe 'ServerVote with Account' do
        it 'creates a ServerWebhookEvent with ServerVote payload that includes Account id' do
          server = create(:server)
          event_type = 'server_votes.create'
          account = create(:account)
          server_vote = create(
            :server_vote,
            reference:    'user_123456',
            remote_ip:    '8.8.8.8',
            server:       server,
            game:         server.game,
            country_code: 'US',
            account:      account,
          )

          described_class.new(server, event_type, server_vote.id).call

          server_webhook_event = ServerWebhookEvent.last
          expect(server_webhook_event.server).to eq(server)
          expect(server_webhook_event.type).to eq(event_type)
          expect(server_webhook_event.status).to eq(ServerWebhookEvent::PENDING)
          expect(server_webhook_event.payload).to eq({
            'server_vote' => {
              'id'           => server_vote.id,
              'reference'    => 'user_123456',
              'remote_ip'    => '8.8.8.8',
              'server_id'    => server.id,
              'game_id'      => server.game.id,
              'country_code' => 'US',
              'account_id'   => account.id,
              'created_at'   => server_vote.created_at.as_json,
            }
          })
        end
      end
    end
  end
end
