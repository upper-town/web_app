# frozen_string_literal: true

module Webhooks
  class BuildEventRequestHeadersAndBody
    include Callable

    attr_reader :webhook_event

    def initialize(webhook_event)
      @webhook_event = webhook_event
    end

    def call
      request_body = build_request_body
      request_headers = build_request_headers(build_request_signature(request_body))

      [request_headers, request_body]
    end

    private

    def build_request_body
      {
        "webhook_event" => {
          "type"              => webhook_event.type,
          "data"              => webhook_event.data,
          "last_published_at" => webhook_event.last_published_at.iso8601,
          "failed_attempts"   => webhook_event.failed_attempts
        }
      }.to_json
    end

    def build_request_headers(request_signature)
      {
        "Content-Type" => "application/json",
        "X-Signature"  => request_signature
      }.compact_blank
    end

    def build_request_signature(request_body)
      secret = webhook_event.config.secret

      OpenSSL::HMAC.hexdigest("sha256", secret, request_body)
    end
  end
end
