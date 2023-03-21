# frozen_string_literal: true

module ServerWebhooks
  class BuildEventRequestHeadersAndBody
    def initialize(server_webhook_event)
      @server_webhook_event = server_webhook_event

      @server_webhook_secrets_active   = @server_webhook_event.server.webhook_secrets.active
      @server_webhook_secrets_archived = @server_webhook_event.server.webhook_secrets.archived
    end

    def call
      request_body = build_request_body!
      request_signatures = build_request_signatures(request_body)
      request_headers = build_request_headers(request_signatures)

      [request_headers, request_body]
    end

    private

    def build_request_body!
      {
        'event' => {
          'id'                => @server_webhook_event.suuid,
          'type'              => @server_webhook_event.type,
          'last_published_at' => @server_webhook_event.last_published_at,
          'failed_attempts'   => @server_webhook_event.failed_attempts,
          'payload'           => @server_webhook_event.payload,
        }
      }.to_json
    end

    def build_request_signatures(request_body)
      active_signatures = @server_webhook_secrets_active.map do |server_webhook_secret|
        generate_signature(server_webhook_secret.value, request_body)
      end

      archived_signatures = @server_webhook_secrets_archived.map do |server_webhook_secret|
        generate_signature(server_webhook_secret.value, request_body)
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
  end
end
