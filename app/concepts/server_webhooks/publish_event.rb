# frozen_string_literal: true

module ServerWebhooks
  class PublishEvent
    TIMEOUT = 60

    def initialize(server_webhook_event)
      @server_webhook_event = server_webhook_event
    end

    def call
      result = check_failed
      return result if result.failure?

      result = check_delivered
      return result if result.failure?

      result = check_and_set_config!
      return result if result.failure?

      try_publish!
    end

    private

    def check_failed
      if @server_webhook_event.failed?
        Result.failure('Cannot retry event: it has been retried and failed multiple times')
      else
        Result.success
      end
    end

    def check_delivered
      if @server_webhook_event.delivered?
        Result.failure('Cannot retry event: it has been delivered already')
      else
        Result.success
      end
    end

    def check_and_set_config!
      server_webhook_config = @server_webhook_event.server.webhook_config

      if server_webhook_config.blank?
        notice = 'Could not find an enabled integration config for webhook event at the time of publishing it'
        retry_in = increment_failed_attempts!(notice)

        Result.failure(
          "May retry event: #{notice}",
          retry_in: retry_in
        )
      else
        @server_webhook_event.update!(config: server_webhook_config)

        Result.success
      end
    end

    def try_publish!
      @server_webhook_event.update!(last_published_at: Time.current)

      request_headers, request_body = BuildEventRequestHeadersAndBody.new(@server_webhook_event).call

      response = build_connection(request_headers).post(nil, request_body)

      if response.success?
        UpdateDeliveredEventJob.perform_async(@server_webhook_event.id)

        Result.success
      else
        notice = "Unsuccessful POST request: HTTP status #{response.status}"
        retry_in = increment_failed_attempts!(notice)

        Result.failure(
          "May retry event: #{notice}",
          retry_in: retry_in,
          check_up_enabled_config_id: @server_webhook_event.config.id
        )
      end
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      notice = "Connection Failed or Timeout Error: #{e}"
      retry_in = increment_failed_attempts!(notice)

      Result.failure(
        "May retry event: #{notice}",
        retry_in: retry_in,
        check_up_enabled_config_id: @server_webhook_event.config.id
      )
    end

    def increment_failed_attempts!(notice)
      @server_webhook_event.increment(:failed_attempts)
      @server_webhook_event.notice = notice
      @server_webhook_event.status = determine_status
      @server_webhook_event.save!

      @server_webhook_event.retry_in
    end

    def determine_status
      if @server_webhook_event.maxed_failed_attempts?
        ServerWebhookEvent::FAILED
      else
        ServerWebhookEvent::RETRY
      end
    end

    def build_connection(headers)
      Faraday.new(
        @server_webhook_event.config.url,
        {
          headers: headers,
          request: { timeout: TIMEOUT }
        }
      )
    end
  end
end
