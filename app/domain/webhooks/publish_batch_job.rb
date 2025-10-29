# frozen_string_literal: true

module Webhooks
  class PublishBatchJob < ApplicationJob
    def perform(webhook_batch)
      return unless webhook_batch.queued?

      begin
        ActiveRecord::Base.transaction do
          webhook_batch.delivered!

          headers, body = BuildEventRequestHeadersAndBody.call(webhook_batch)
          send_request(webhook_batch, headers, body)
        end
      rescue StandardError => e
        webhook_batch.not_delivered!(
          {
            "failed_attempts" => {
              (webhook_batch.failed_attempts + 1) => "#{e.class}: #{e.message}: #{Time.current.iso8601}"
            }
          }
        )

        raise e
      end
    end

    private

    def send_request(webhook_batch, headers, body)
      connection = Faraday.new(url: webhook_batch.config.url, headers:) do |builder|
        builder.response :raise_error
      end

      case webhook_batch.config.method
      when "POST"  then connection.post(nil, body)
      when "PUT"   then connection.put(nil, body)
      when "PATCH" then connection.patch(nil, body)
      else
        raise "HTTP method not supported for webhook request"
      end
    end
  end
end
