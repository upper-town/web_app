# frozen_string_literal: true

module Demo
  module Webhooks
    class Request
      attr_reader :request, :request_body

      def initialize(request)
        @request = request
        @request_body = request.body.read
      end

      def valid?
        ActiveSupport::SecurityUtils.secure_compare(
          OpenSSL::HMAC.hexdigest("sha256", ENV.fetch("DEMO_WEBHOOK_SECRET"), request_body),
          request.headers["X-Signature"]
        )
      end

      def webhook_event_hashes
        JSON.parse(request_body).map do |webhook_event_hash|
          {
            uuid:       webhook_event_hash["uuid"],
            type:       webhook_event_hash["type"],
            data:       webhook_event_hash["data"],
            metadata:   webhook_event_hash["metadata"],
            created_at: webhook_event_hash["created_at"]
          }
        end
      end
    end
  end
end
