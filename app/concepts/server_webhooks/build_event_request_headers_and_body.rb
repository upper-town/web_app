# frozen_string_literal: true

module ServerWebhooks
  class BuildEventRequestHeadersAndBody
    SIGNATURE_HEADER = 'X-Upper-Town-Server-Webhook-Signature'

    attr_reader :server_webhook_event

    def initialize(server_webhook_event)
      @server_webhook_event = server_webhook_event
    end

    def call
      request_body = build_request_body
      request_signatures = build_request_signatures(request_body)
      request_headers = build_request_headers(request_signatures)

      [request_headers, request_body]
    end

    private

    def build_request_body
      {
        'event' => {
          'type'              => server_webhook_event.type,
          'last_published_at' => server_webhook_event.last_published_at,
          'failed_attempts'   => server_webhook_event.failed_attempts,
          'payload'           => server_webhook_event.payload,
        }
      }.to_json
    end

    def build_request_signatures(request_body)
      active_signatures = active_server_webhook_secrets_query.map do |value|
        generate_signature(value, request_body)
      end

      archived_signatures = archived_server_webhook_secrets_query.map do |value|
        generate_signature(value, request_body)
      end

      active_signatures + archived_signatures
    end

    def build_request_headers(request_signatures)
      {
        'Content-Type'   => 'application/json',
        SIGNATURE_HEADER => request_signatures.join(',')
      }.compact_blank
    end

    def generate_signature(secret, request_body)
      OpenSSL::HMAC.hexdigest('sha256', secret, request_body)
    end

    def active_server_webhook_secrets_query
      ServerWebhookSecret
        .active
        .where(server_id: server_webhook_event.server_id)
        .pluck(:value)
    end

    def archived_server_webhook_secrets_query
      ServerWebhookSecret
        .archived
        .where(server_id: server_webhook_event.server_id)
        .pluck(:value)
    end
  end
end
