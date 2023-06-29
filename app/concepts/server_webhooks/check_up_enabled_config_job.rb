# frozen_string_literal: true

module ServerWebhooks
  class CheckUpEnabledConfigJob
    include Sidekiq::Job

    MAX_RECENT_EVENTS_IN_RETRY_OR_FAILED = 50

    sidekiq_options(lock: :while_executing)

    def perform(server_webhook_config_id)
      @server_webhook_config = ServerWebhookConfig.find_by(id: server_webhook_config_id)
      return unless @server_webhook_config
      return unless @server_webhook_config.enabled?

      check_up
    end

    private

    def check_up
      if count_recent_events_in_retry_or_failed >= MAX_RECENT_EVENTS_IN_RETRY_OR_FAILED
        disable!
        schedule_notification
      end
    end

    def count_recent_events_in_retry_or_failed
      recent_event_statuses.count do |status|
        [
          ServerWebhookEvent::RETRY,
          ServerWebhookEvent::FAILED
        ].include?(status)
      end
    end

    def recent_event_statuses
      @server_webhook_config
        .events
        .where.not(status: ServerWebhookEvent::PENDING)
        .order(updated_at: :desc)
        .limit(MAX_RECENT_EVENTS_IN_RETRY_OR_FAILED)
        .pluck(:status)
    end

    def disable!
      @server_webhook_config.update!(
        disabled_at: Time.current,
        notice: 'Too many recent events in "retry" or "failed" status ' \
          'due to Connection Failed or Timeout Error'
      )
    end

    def schedule_notification
      NotifyDisabledConfigJob.perform_async(@server_webhook_config.id)
    end
  end
end
