# frozen_string_literal: true

module ServerWebhooks
  class PublishEvent
    include Callable

    attr_reader :server_webhook_event

    def initialize(server_webhook_event)
      @server_webhook_event = server_webhook_event
    end

    def call
      result = check_failed
      return result if result.failure?

      result = check_delivered
      return result if result.failure?

      result = check_config
      return result if result.failure?

      try_publish!
    end

    private

    def check_failed
      if server_webhook_event.failed?
        Result.failure('Could not retry event: it has been retried and failed multiple times')
      else
        Result.success
      end
    end

    def check_delivered
      if server_webhook_event.delivered?
        Result.failure('Cannot retry event: it has been delivered already')
      else
        Result.success
      end
    end

    def check_config
      notice =
        if server_webhook_event.config.blank?
          'Could not find config for this event type at the time of publishing it'
        elsif server_webhook_event.config.not_subscribed?(server_webhook_event.type)
          'Could not find config that is subscribed to this event type at the time of publishing it'
        elsif server_webhook_event.config.disabled?
          'Could not find an enabled config for this event type at the time of publishing it'
        end

      if notice.present?
        result_failure_retry(notice)
      else
        Result.success
      end
    end

    def try_publish!
      server_webhook_event.update!(last_published_at: Time.current)
      headers, body = BuildEventRequestHeadersAndBody.call(server_webhook_event)

      send_request(build_connection(headers), body)

      UpdateDeliveredEventJob.perform_async(server_webhook_event.id)

      Result.success
    rescue Faraday::ClientError, Faraday::ServerError => e
      result_failure_retry("Request failed: #{e}")
    rescue Faraday::Error => e
      result_failure_retry("Connection failed: #{e}")
    end

    def result_failure_retry(notice)
      retry_in = increment_failed_attempts!(notice)

      Result.failure("May retry event: #{notice}", retry_in: retry_in)
    end

    def increment_failed_attempts!(notice)
      server_webhook_event.increment(:failed_attempts)
      server_webhook_event.update!(
        notice: notice,
        status: determine_status
      )

      server_webhook_event.retry_in
    end

    def determine_status
      if server_webhook_event.maxed_failed_attempts?
        ServerWebhookEvent::FAILED
      else
        ServerWebhookEvent::RETRY
      end
    end

    def build_connection(headers)
      Faraday.new(
        url: server_webhook_event.config.url,
        headers: headers
      ) do |builder|
        builder.response :raise_error
      end
    end

    def send_request(connection, body)
      case server_webhook_event.config.method
      when 'POST'  then connection.post(nil, body)
      when 'PUT'   then connection.put(nil, body)
      when 'PATCH' then connection.patch(nil, body)
      else
        raise 'HTTP method not supported for webhook request'
      end
    end
  end
end
