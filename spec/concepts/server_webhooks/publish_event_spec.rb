# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerWebhooks::PublishEvent do
  describe '#call' do
    context 'when server_webhook_event has already failed' do
      it 'returns failure and does not try to publish' do
        server_webhook_config = create(
          :server_webhook_config,
          method: 'POST',
          url: 'https://game.company.com/webhook_events',
          disabled_at: nil,
          event_types: ['test.event'],
          secret: 'aaaaaaaa'
        )
        server_webhook_event = create(
          :server_webhook_event,
          config: server_webhook_config,
          type: 'test.event',
          status: 'failed'
        )
        publish_event_request = stub_publish_event_request(
          url: 'https://game.company.com/webhook_events'
        )

        result = described_class.new(server_webhook_event).call

        expect(publish_event_request).not_to have_been_requested
        expect(ServerWebhooks::UpdateDeliveredEventJob).not_to have_enqueued_sidekiq_job

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Could not retry event: it has been retried and failed multiple times/)
      end
    end

    context 'when server_webhook_event has already been delivered' do
      it 'returns failure and does not try to publish' do
        server_webhook_config = create(
          :server_webhook_config,
          method: 'POST',
          url: 'https://game.company.com/webhook_events',
          disabled_at: nil,
          event_types: ['test.event'],
          secret: 'aaaaaaaa'
        )
        server_webhook_event = create(
          :server_webhook_event,
          config: server_webhook_config,
          type: 'test.event',
          status: 'delivered'
        )
        publish_event_request = stub_publish_event_request(
          url: 'https://game.company.com/webhook_events'
        )

        result = described_class.new(server_webhook_event).call

        expect(publish_event_request).not_to have_been_requested
        expect(ServerWebhooks::UpdateDeliveredEventJob).not_to have_enqueued_sidekiq_job

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Cannot retry event: it has been delivered already/)
      end
    end

    context 'when server_webhook_event config is blank' do
      it 'returns failure with retry_in and does not try to publish' do
        _server_webhook_config = create(
          :server_webhook_config,
          method: 'POST',
          url: 'https://game.company.com/webhook_events',
          disabled_at: nil,
          event_types: ['test.event'],
          secret: 'aaaaaaaa'
        )
        server_webhook_event = create(
          :server_webhook_event,
          config: nil,
          type: 'test.event',
          status: 'pending'
        )
        publish_event_request = stub_publish_event_request(
          url: 'https://game.company.com/webhook_events'
        )

        result = described_class.new(server_webhook_event).call

        expect(publish_event_request).not_to have_been_requested
        expect(ServerWebhooks::UpdateDeliveredEventJob).not_to have_enqueued_sidekiq_job

        server_webhook_event.reload
        expect(server_webhook_event.failed_attempts).to eq(1)
        expect(server_webhook_event.notice).to eq('Could not find config for this event type at the time of publishing it')
        expect(server_webhook_event.status).to eq('retry')

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/May retry event/)
        expect(result.data[:retry_in]).to be_present
      end
    end

    context 'when server_webhook_event config is not subscribed to event_type anymore' do
      it 'returns failure with retry_in and does not try to publish' do
        server_webhook_config = create(
          :server_webhook_config,
          method: 'POST',
          url: 'https://game.company.com/webhook_events',
          disabled_at: nil,
          event_types: ['something.else'],
          secret: 'aaaaaaaa'
        )
        server_webhook_event = create(
          :server_webhook_event,
          config: server_webhook_config,
          type: 'test.event',
          status: 'pending'
        )
        publish_event_request = stub_publish_event_request(
          url: 'https://game.company.com/webhook_events'
        )

        result = described_class.new(server_webhook_event).call

        expect(publish_event_request).not_to have_been_requested
        expect(ServerWebhooks::UpdateDeliveredEventJob).not_to have_enqueued_sidekiq_job

        server_webhook_event.reload
        expect(server_webhook_event.failed_attempts).to eq(1)
        expect(server_webhook_event.notice).to eq('Could not find config that is subscribed to this event type at the time of publishing it')
        expect(server_webhook_event.status).to eq('retry')

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/May retry event: #{server_webhook_event.notice}/)
        expect(result.data[:retry_in]).to be_present
      end
    end

    context 'when server_webhook_event config is disabled' do
      it 'returns failure with retry_in and does not try to publish' do
        server_webhook_config = create(
          :server_webhook_config,
          method: 'POST',
          url: 'https://game.company.com/webhook_events',
          disabled_at: Time.current,
          event_types: ['test.event'],
          secret: 'aaaaaaaa'
        )
        server_webhook_event = create(
          :server_webhook_event,
          config: server_webhook_config,
          type: 'test.event',
          status: 'pending'
        )
        publish_event_request = stub_publish_event_request(
          url: 'https://game.company.com/webhook_events'
        )

        result = described_class.new(server_webhook_event).call

        expect(publish_event_request).not_to have_been_requested
        expect(ServerWebhooks::UpdateDeliveredEventJob).not_to have_enqueued_sidekiq_job

        server_webhook_event.reload
        expect(server_webhook_event.failed_attempts).to eq(1)
        expect(server_webhook_event.notice).to eq('Could not find an enabled config for this event type at the time of publishing it')
        expect(server_webhook_event.status).to eq('retry')

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/May retry event: #{server_webhook_event.notice}/)
        expect(result.data[:retry_in]).to be_present
      end
    end

    context 'when event and config are OK' do
      context 'when request to publish responds with 4xx status' do
        it 'returns failure with retry_in' do
          freeze_time do
            server_webhook_config = create(
              :server_webhook_config,
              method: 'POST',
              url: 'https://game.company.com/webhook_events',
              disabled_at: nil,
              event_types: ['test.event'],
              secret: 'aaaaaaaa'
            )
            server_webhook_event = create(
              :server_webhook_event,
              config: server_webhook_config,
              type: 'test.event',
              status: 'pending',
              payload: { 'server_vote' => { 'uuid' => '11111111-1111-1111-1111-111111111111' } },
              last_published_at: nil,
              failed_attempts: 0,
              notice: ''
            )
            expected_body = {
              'webhook_event' => {
                'type' => 'test.event',
                'payload' => server_webhook_event.payload,
                'last_published_at' => Time.current.iso8601,
                'failed_attempts' => 0,
              }
            }.to_json
            expected_headers = {
              'Content-Type' => 'application/json',
              'X-Signature' => OpenSSL::HMAC.hexdigest('sha256', 'aaaaaaaa', expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: 'https://game.company.com/webhook_events',
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_status: 400
            )

            result = described_class.new(server_webhook_event).call

            expect(publish_event_request).to have_been_requested
            expect(ServerWebhooks::UpdateDeliveredEventJob).not_to have_enqueued_sidekiq_job

            server_webhook_event.reload
            expect(server_webhook_event.status).to eq('retry')
            expect(server_webhook_event.last_published_at).to eq(Time.current)
            expect(server_webhook_event.failed_attempts).to eq(1)
            expect(server_webhook_event.notice).to match(/Request failed/)

            expect(result.failure?).to be(true)
            expect(result.errors[:base]).to include(/May retry event/)
            expect(result.data[:retry_in]).to be_present
          end
        end
      end

      context 'when request to publish responds with 5xx status' do
        it 'returns failure with retry_in' do
          freeze_time do
            server_webhook_config = create(
              :server_webhook_config,
              method: 'POST',
              url: 'https://game.company.com/webhook_events',
              disabled_at: nil,
              event_types: ['test.event'],
              secret: 'aaaaaaaa'
            )
            server_webhook_event = create(
              :server_webhook_event,
              config: server_webhook_config,
              type: 'test.event',
              status: 'pending',
              payload: { 'server_vote' => { 'uuid' => '11111111-1111-1111-1111-111111111111' } },
              last_published_at: nil,
              failed_attempts: 0,
              notice: ''
            )
            expected_body = {
              'webhook_event' => {
                'type' => 'test.event',
                'payload' => server_webhook_event.payload,
                'last_published_at' => Time.current.iso8601,
                'failed_attempts' => 0,
              }
            }.to_json
            expected_headers = {
              'Content-Type' => 'application/json',
              'X-Signature' => OpenSSL::HMAC.hexdigest('sha256', 'aaaaaaaa', expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: 'https://game.company.com/webhook_events',
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_status: 500
            )

            result = described_class.new(server_webhook_event).call

            expect(publish_event_request).to have_been_requested
            expect(ServerWebhooks::UpdateDeliveredEventJob).not_to have_enqueued_sidekiq_job

            server_webhook_event.reload
            expect(server_webhook_event.status).to eq('retry')
            expect(server_webhook_event.last_published_at).to eq(Time.current)
            expect(server_webhook_event.failed_attempts).to eq(1)
            expect(server_webhook_event.notice).to match(/Request failed/)

            expect(result.failure?).to be(true)
            expect(result.errors[:base]).to include(/May retry event/)
            expect(result.data[:retry_in]).to be_present
          end
        end
      end

      context 'when request to publish times out' do
        it 'returns failure with retry_in' do
          freeze_time do
            server_webhook_config = create(
              :server_webhook_config,
              method: 'POST',
              url: 'https://game.company.com/webhook_events',
              disabled_at: nil,
              event_types: ['test.event'],
              secret: 'aaaaaaaa'
            )
            server_webhook_event = create(
              :server_webhook_event,
              config: server_webhook_config,
              type: 'test.event',
              status: 'pending',
              payload: { 'server_vote' => { 'uuid' => '11111111-1111-1111-1111-111111111111' } },
              last_published_at: nil,
              failed_attempts: 0,
              notice: ''
            )
            expected_body = {
              'webhook_event' => {
                'type' => 'test.event',
                'payload' => server_webhook_event.payload,
                'last_published_at' => Time.current.iso8601,
                'failed_attempts' => 0,
              }
            }.to_json
            expected_headers = {
              'Content-Type' => 'application/json',
              'X-Signature' => OpenSSL::HMAC.hexdigest('sha256', 'aaaaaaaa', expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: 'https://game.company.com/webhook_events',
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_timeout: true
            )

            result = described_class.new(server_webhook_event).call

            expect(publish_event_request).to have_been_requested
            expect(ServerWebhooks::UpdateDeliveredEventJob).not_to have_enqueued_sidekiq_job

            server_webhook_event.reload
            expect(server_webhook_event.status).to eq('retry')
            expect(server_webhook_event.last_published_at).to eq(Time.current)
            expect(server_webhook_event.failed_attempts).to eq(1)
            expect(server_webhook_event.notice).to match(/Connection failed/)

            expect(result.failure?).to be(true)
            expect(result.errors[:base]).to include(/May retry event/)
            expect(result.data[:retry_in]).to be_present
          end
        end
      end

      context 'when there are multiple failures' do
        it 'returns failure with retry_in nil and status failed' do
          freeze_time do
            server_webhook_config = create(
              :server_webhook_config,
              method: 'POST',
              url: 'https://game.company.com/webhook_events',
              disabled_at: nil,
              event_types: ['test.event'],
              secret: 'aaaaaaaa'
            )
            server_webhook_event = create(
              :server_webhook_event,
              config: server_webhook_config,
              type: 'test.event',
              status: 'pending',
              payload: { 'server_vote' => { 'uuid' => '11111111-1111-1111-1111-111111111111' } },
              last_published_at: nil,
              failed_attempts: 24,
              notice: ''
            )
            expected_body = {
              'webhook_event' => {
                'type' => 'test.event',
                'payload' => server_webhook_event.payload,
                'last_published_at' => Time.current.iso8601,
                'failed_attempts' => 24,
              }
            }.to_json
            expected_headers = {
              'Content-Type' => 'application/json',
              'X-Signature' => OpenSSL::HMAC.hexdigest('sha256', 'aaaaaaaa', expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: 'https://game.company.com/webhook_events',
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_status: 400
            )

            result = described_class.new(server_webhook_event).call

            expect(publish_event_request).to have_been_requested
            expect(ServerWebhooks::UpdateDeliveredEventJob).not_to have_enqueued_sidekiq_job

            server_webhook_event.reload
            expect(server_webhook_event.status).to eq('failed')
            expect(server_webhook_event.last_published_at).to eq(Time.current)
            expect(server_webhook_event.failed_attempts).to eq(25)
            expect(server_webhook_event.notice).to match(/Request failed/)

            expect(result.failure?).to be(true)
            expect(result.errors[:base]).to include(/May retry event/)
            expect(result.data[:retry_in]).to be_nil
          end
        end
      end

      context 'when request to publish responds with 2xx status' do
        it 'returns success' do
          freeze_time do
            server_webhook_config = create(
              :server_webhook_config,
              method: 'POST',
              url: 'https://game.company.com/webhook_events',
              disabled_at: nil,
              event_types: ['test.event'],
              secret: 'aaaaaaaa'
            )
            server_webhook_event = create(
              :server_webhook_event,
              config: server_webhook_config,
              type: 'test.event',
              status: 'pending',
              payload: { 'server_vote' => { 'uuid' => '11111111-1111-1111-1111-111111111111' } },
              last_published_at: nil,
              failed_attempts: 0,
              notice: ''
            )
            expected_body = {
              'webhook_event' => {
                'type' => 'test.event',
                'payload' => server_webhook_event.payload,
                'last_published_at' => Time.current.iso8601,
                'failed_attempts' => 0,
              }
            }.to_json
            expected_headers = {
              'Content-Type' => 'application/json',
              'X-Signature' => OpenSSL::HMAC.hexdigest('sha256', 'aaaaaaaa', expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: 'https://game.company.com/webhook_events',
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_status: 200
            )

            result = described_class.new(server_webhook_event).call

            expect(publish_event_request).to have_been_requested
            expect(ServerWebhooks::UpdateDeliveredEventJob).to have_enqueued_sidekiq_job(server_webhook_event.id)

            server_webhook_event.reload
            expect(server_webhook_event.status).to eq('pending')
            expect(server_webhook_event.last_published_at).to eq(Time.current)
            expect(server_webhook_event.failed_attempts).to eq(0)
            expect(server_webhook_event.notice).to eq('')

            expect(result.success?).to be(true)
          end
        end

        describe 'other config methods' do
          it 'works with PUT' do
            freeze_time do
              server_webhook_config = create(
                :server_webhook_config,
                method: 'PUT',
                url: 'https://game.company.com/webhook_events',
                disabled_at: nil,
                event_types: ['test.event'],
                secret: 'aaaaaaaa'
              )
              server_webhook_event = create(
                :server_webhook_event,
                config: server_webhook_config,
                type: 'test.event',
                status: 'pending',
                payload: { 'server_vote' => { 'uuid' => '11111111-1111-1111-1111-111111111111' } },
                last_published_at: nil,
                failed_attempts: 0,
                notice: ''
              )
              expected_body = {
                'webhook_event' => {
                  'type' => 'test.event',
                  'payload' => server_webhook_event.payload,
                  'last_published_at' => Time.current.iso8601,
                  'failed_attempts' => 0,
                }
              }.to_json
              expected_headers = {
                'Content-Type' => 'application/json',
                'X-Signature' => OpenSSL::HMAC.hexdigest('sha256', 'aaaaaaaa', expected_body)
              }
              publish_event_request = stub_publish_event_request(
                url: 'https://game.company.com/webhook_events',
                method: :put,
                headers: expected_headers,
                body: expected_body,
                response_status: 200
              )

              result = described_class.new(server_webhook_event).call

              expect(publish_event_request).to have_been_requested
              expect(ServerWebhooks::UpdateDeliveredEventJob).to have_enqueued_sidekiq_job(server_webhook_event.id)

              server_webhook_event.reload
              expect(server_webhook_event.status).to eq('pending')
              expect(server_webhook_event.last_published_at).to eq(Time.current)
              expect(server_webhook_event.failed_attempts).to eq(0)
              expect(server_webhook_event.notice).to eq('')

              expect(result.success?).to be(true)
            end
          end

          it 'works with PATCH' do
            freeze_time do
              server_webhook_config = create(
                :server_webhook_config,
                method: 'PATCH',
                url: 'https://game.company.com/webhook_events',
                disabled_at: nil,
                event_types: ['test.event'],
                secret: 'aaaaaaaa'
              )
              server_webhook_event = create(
                :server_webhook_event,
                config: server_webhook_config,
                type: 'test.event',
                status: 'pending',
                payload: { 'server_vote' => { 'uuid' => '11111111-1111-1111-1111-111111111111' } },
                last_published_at: nil,
                failed_attempts: 0,
                notice: ''
              )
              expected_body = {
                'webhook_event' => {
                  'type' => 'test.event',
                  'payload' => server_webhook_event.payload,
                  'last_published_at' => Time.current.iso8601,
                  'failed_attempts' => 0,
                }
              }.to_json
              expected_headers = {
                'Content-Type' => 'application/json',
                'X-Signature' => OpenSSL::HMAC.hexdigest('sha256', 'aaaaaaaa', expected_body)
              }
              publish_event_request = stub_publish_event_request(
                url: 'https://game.company.com/webhook_events',
                method: :patch,
                headers: expected_headers,
                body: expected_body,
                response_status: 200
              )

              result = described_class.new(server_webhook_event).call

              expect(publish_event_request).to have_been_requested
              expect(ServerWebhooks::UpdateDeliveredEventJob).to have_enqueued_sidekiq_job(server_webhook_event.id)

              server_webhook_event.reload
              expect(server_webhook_event.status).to eq('pending')
              expect(server_webhook_event.last_published_at).to eq(Time.current)
              expect(server_webhook_event.failed_attempts).to eq(0)
              expect(server_webhook_event.notice).to eq('')

              expect(result.success?).to be(true)
            end
          end
        end
      end
    end
  end

  def stub_publish_event_request(
    url:,
    method: :any,
    headers: nil,
    body: nil,
    response_status: 200,
    response_headers: { 'Content-Type' => 'text/plain' },
    response_body: nil,
    response_timeout: false
  )
    request = stub_request(method, url)
    request = request.with(headers: headers) if !headers.nil?
    request = request.with(body: body) if !body.nil?

    if response_timeout
      request.to_timeout
    else
      request.to_return(
        status: response_status,
        headers: response_headers,
        body: response_body.to_json,
      )
    end
  end
end
