# frozen_string_literal: true

module ServerWebhooks
  class NotifyDisabledConfigJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    attr_reader :server_webhook_config

    def perform(server_webhook_config_id)
      @server_webhook_config = ServerWebhookConfig.find_by(id: server_webhook_config_id)
      return unless server_webhook_config
      return unless server_webhook_config.disabled?

      # TODO: implement this notification!
    end
  end
end
