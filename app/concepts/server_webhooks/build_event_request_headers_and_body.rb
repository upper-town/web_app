# frozen_string_literal: true

module ServerWebhooks
  class BuildEventRequestHeadersAndBody
    include Callable

    attr_reader :server_webhook_event

    def initialize(server_webhook_event)
      @server_webhook_event = server_webhook_event
    end

    def call
      request_body = build_request_body
      request_signature = build_request_signature(request_body)
      request_other_signature = build_request_other_signature(request_body)
      request_headers = build_request_headers(request_signature, request_other_signature)

      [request_headers, request_body]
    end

    private

    def build_request_body
      {
        'webhook_event' => {
          'type'              => server_webhook_event.type,
          'payload'           => server_webhook_event.payload,
          'last_published_at' => server_webhook_event.last_published_at.iso8601,
          'failed_attempts'   => server_webhook_event.failed_attempts,
        }
      }.to_json
    end

    def build_request_signature(request_body)
      secret = server_webhook_event.config.secret

      generate_signature(secret, request_body)
    end

    def build_request_other_signature(request_body)
      other_secret = server_webhook_event.config.other_secret
      return if other_secret.blank?

      generate_signature(other_secret, request_body)
    end

    def build_request_headers(request_signature, request_other_signature)
      {
        'Content-Type'      => 'application/json',
        'X-Signature'       => request_signature,
        'X-Other-Signature' => request_other_signature,
      }.compact_blank
    end

    def generate_signature(secret, request_body)
      OpenSSL::HMAC.hexdigest('sha256', secret, request_body)
    end
  end
end
