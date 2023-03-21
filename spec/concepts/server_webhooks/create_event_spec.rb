# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::CreateEvent do
  describe '#call' do
    context 'when event_type is unknown' do
      it 'raises an error' do
        expect do
          described_class.new(any_args, 'an_unknown.event_type', nil).call
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

      describe 'ServerVote without UserAccount' do
        it 'creates a ServerWebhookEvent with ServerVote payload' do
          server = create(:server)
          event_type = 'server_votes.create'
          server_vote = create(
            :server_vote,
            reference:    'user_123456',
            remote_ip:    '8.8.8.8',
            server:       server,
            app:          server.app,
            country_code: 'US',
            user_account: nil,
          )

          described_class.new(server, event_type, server_vote.id).call

          server_webhook_event = ServerWebhookEvent.last
          expect(server_webhook_event.uuid).to be_present
          expect(server_webhook_event.server).to eq(server)
          expect(server_webhook_event.type).to eq(event_type)
          expect(server_webhook_event.status).to eq(ServerWebhookEvent::PENDING)
          expect(server_webhook_event.payload).to eq({
            'server_vote' => {
              'id'              => server_vote.suuid,
              'reference'       => 'user_123456',
              'remote_ip'       => '8.8.8.8',
              'server_id'       => server.suuid,
              'app_id'          => server.app.suuid,
              'country_code'    => 'US',
              'user_account_id' => nil,
              'created_at'      => server_vote.created_at.as_json,
            }
          })
        end
      end

      describe 'ServerVote with UserAccount' do
        it 'creates a ServerWebhookEvent with ServerVote payload that includes UserAccount suuid' do
          server = create(:server)
          event_type = 'server_votes.create'
          user_account = create(:user_account)
          server_vote = create(
            :server_vote,
            reference:    'user_123456',
            remote_ip:    '8.8.8.8',
            server:       server,
            app:          server.app,
            country_code: 'US',
            user_account: user_account,
          )

          described_class.new(server, event_type, server_vote.id).call

          server_webhook_event = ServerWebhookEvent.last
          expect(server_webhook_event.uuid).to be_present
          expect(server_webhook_event.server).to eq(server)
          expect(server_webhook_event.type).to eq(event_type)
          expect(server_webhook_event.status).to eq(ServerWebhookEvent::PENDING)
          expect(server_webhook_event.payload).to eq({
            'server_vote' => {
              'id'              => server_vote.suuid,
              'reference'       => 'user_123456',
              'remote_ip'       => '8.8.8.8',
              'server_id'       => server.suuid,
              'app_id'          => server.app.suuid,
              'country_code'    => 'US',
              'user_account_id' => user_account.suuid,
              'created_at'      => server_vote.created_at.as_json,
            }
          })
        end
      end
    end
  end
end
