# frozen_string_literal: true

module Webhooks
  class PublishEvent
    include Callable

    class Result < ApplicationResult
      attribute :retry_in
    end

    attr_reader :webhook_event

    # TODO: Add arg n = 1 max number of events to fetch from database and send
    def initialize(webhook_event)
      @webhook_event = webhook_event
    end

    def call
      result = check_failed
      return result if result.failure?

      result = check_delivered
      return result if result.failure?

      result = check_config
      return result if result.failure?

      # TODO: select from database and send array of send array of webhook_events
      # instead of one event at a time
      try_publish

      # TODO: remove  prefix from webhook tables
      # TODO: create webhook_config_events and associate an event with a config and move delivered_at there
      # TODO: when publish a job, take a config arg
    end

    private

    def check_failed
      if webhook_event.failed?
        Result.failure("Could not retry event: it has been retried and failed multiple times")
      else
        Result.success
      end
    end

    def check_delivered
      if webhook_event.delivered?
        Result.failure("Cannot retry event: it has been delivered already")
      else
        Result.success
      end
    end

    def check_config
      notice =
        if webhook_event.config.blank?
          "Could not find config for this event type at the time of publishing it"
        elsif webhook_event.config.not_subscribed?(webhook_event.type)
          "Could not find config that is subscribed to this event type at the time of publishing it"
        elsif webhook_event.config.disabled?
          "Could not find an enabled config for this event type at the time of publishing it"
        end

      if notice.present?
        result_failure_retry(notice)
      else
        Result.success
      end
    end

    def try_publish
      webhook_event.update!(last_published_at: Time.current)
      headers, body = BuildEventRequestHeadersAndBody.call(webhook_event)

      send_request(build_connection(headers), body)

      # TODO: for sending array of webhook events, make this inline and within a
      # transaction so it rolls back if the delivery fails
      UpdateDeliveredEventJob.perform_later(webhook_event)

      Result.success
    rescue Faraday::ClientError, Faraday::ServerError => e
      result_failure_retry("Request failed: #{e}")
    rescue Faraday::Error => e
      result_failure_retry("Connection failed: #{e}")
    end

    def result_failure_retry(notice)
      retry_in = increment_failed_attempts!(notice)

      Result.failure("May retry event: #{notice}", retry_in:)
    end

    def increment_failed_attempts!(notice)
      webhook_event.increment(:failed_attempts)
      webhook_event.update!(
        metadata: { notice: },
        status: determine_status
      )

      webhook_event.retry_in
    end

    def determine_status
      if webhook_event.maxed_failed_attempts?
        WebhookEvent::FAILED
      else
        WebhookEvent::RETRY
      end
    end

    def build_connection(headers)
      Faraday.new(
        url: webhook_event.config.url,
        headers:
      ) do |builder|
        builder.response :raise_error
      end
    end

    def send_request(connection, body)
      case webhook_event.config.method
      when "POST"  then connection.post(nil, body)
      when "PUT"   then connection.put(nil, body)
      when "PATCH" then connection.patch(nil, body)
      else
        raise "HTTP method not supported for webhook request"
      end
    end
  end
end
