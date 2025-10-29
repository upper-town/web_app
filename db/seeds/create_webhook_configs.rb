# frozen_string_literal: true

module Seeds
  class CreateWebhookConfigs
    include Callable

    def call
      result = WebhookConfig.insert_all(webhook_config_hashes)

      result.rows.flatten # webhook_config_ids
    end

    private

    def webhook_config_hashes
      [
        {
          source_type: "Server",
          source_id:   100,
          event_types: ["*"],
          method:      "POST",
          url:         "#{ENV.fetch('DEMO_SITE_URL')}/webhook_events",
          secret:      ENV.fetch("DEMO_WEBHOOK_SECRET"),
          disabled_at: false
        },
      ]
    end
  end
end
