# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
RSpec.describe ServerWebhooks::BuildEventRequestHeadersAndBody do
  describe '#call' do
    context 'when server does not have any ServerWebhookSecrets' do
      it 'returns request_headers without SIGNATURE_HEADER, and returns request_body accordingly' do
        server = create(:server)
        server_webhook_event = create(
          :server_webhook_event,
          server:            server,
          type:              'test.event_type',
          last_published_at: '2023-03-20T12:50:01Z',
          failed_attempts:    1,
          payload:            { 'server_vote' => { 'id' => 123 } }
        )

        request_headers, request_body = described_class.new(server_webhook_event).call

        expect(request_headers).to eq({
          'Content-Type' => 'application/json',
        })
        expect(request_body).to eq({
          'event' => {
            'type'              => 'test.event_type',
            'last_published_at' => '2023-03-20T12:50:01.000Z',
            'failed_attempts'   => 1,
            'payload'           => { 'server_vote' => { 'id' => 123 } },
          }
        }.to_json)
      end
    end

    context 'when server has ServerWebhookSecrets' do
      it 'returns request_headers and request_body accordingly' do
        server = create(:server)
        create(
          :server_webhook_secret,
          server:      server,
          value:      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          archived_at: Time.current
        )
        create(
          :server_webhook_secret,
          server:      server,
          value:       'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          archived_at: nil
        )
        server_webhook_event = create(
          :server_webhook_event,
          server:            server,
          type:              'test.event_type',
          last_published_at: '2023-03-20T12:50:01Z',
          failed_attempts:    1,
          payload:            { 'server_vote' => { 'id' => 123 } }
        )

        request_headers, request_body = described_class.new(server_webhook_event).call

        expect(request_headers).to eq({
          'Content-Type'                          => 'application/json',
          'X-Upper-Town-Server-Webhook-Signature' => 'ee6e31886acf4d0ccfd252db2e39d436730d29b8c0ece6ba4b7f0fcfbc4416dc,509ae33223ef90d03adefa98e22c6728c65f2b31007b1ff2dfe1299e33034201'
        })
        expect(request_body).to eq({
          'event' => {
            'type'              => 'test.event_type',
            'last_published_at' => '2023-03-20T12:50:01.000Z',
            'failed_attempts'   => 1,
            'payload'           => { 'server_vote' => { 'id' => 123 } },
          }
        }.to_json)
      end
    end
  end
end
# rubocop:enable Layout/LineLength
