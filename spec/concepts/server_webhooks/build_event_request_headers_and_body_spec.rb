# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::BuildEventRequestHeadersAndBody do
  describe '#call' do
    it 'returns request_headers and request_body accordingly' do
      server = create(:server)
      server_webhook_config = create(
        :server_webhook_config,
        server: server,
        secret: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      )
      server_webhook_event = create(
        :server_webhook_event,
        server: server,
        config: server_webhook_config,
        type: 'test.event',
        last_published_at: '2024-09-02T12:00:01Z',
        failed_attempts: 1,
        payload: { 'server_vote' => { 'uuid' => '11111111-1111-1111-1111-111111111111' } }
      )

      request_headers, request_body = described_class.new(server_webhook_event).call

      expect(request_headers).to eq({
        'Content-Type' => 'application/json',
        'X-Signature'  => '42026a10921d68149b440c2a5d718e65c2259a0d8acbb6c7087fe993040400a6'
      })
      expect(request_body).to eq({
        'webhook_event' => {
          'type'              => 'test.event',
          'payload'           => { 'server_vote' => { 'uuid' => '11111111-1111-1111-1111-111111111111' } },
          'last_published_at' => '2024-09-02T12:00:01Z',
          'failed_attempts'   => 1,
        }
      }.to_json)
    end
  end
end
