# frozen_string_literal: true

module Webhooks
  class BuildEventRequestHeadersAndBody
    include Callable

    attr_reader :webhook_batch

    def initialize(webhook_batch)
      @webhook_batch = webhook_batch
    end

    def call
      request_body = build_request_body
      request_headers = build_request_headers(build_request_signature(request_body))

      [request_headers, request_body]
    end

    private

    def build_request_body
      webhook_batch.events.map do |webhook_event|
        {
          "uuid"       => webhook_event.uuid,
          "type"       => webhook_event.type,
          "data"       => webhook_event.data,
          "metadata"   => webhook_event.metadata,
          "created_at" => webhook_event.created_at
        }
      end.to_json
    end

    def build_request_headers(request_signature)
      {
        "Content-Type" => "application/json",
        "X-Signature"  => request_signature
      }.compact_blank
    end

    def build_request_signature(request_body)
      secret = webhook_batch.config.secret

      OpenSSL::HMAC.hexdigest("sha256", secret, request_body)
    end
  end
end
