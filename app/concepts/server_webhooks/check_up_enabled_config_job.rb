# frozen_string_literal: true

module ServerWebhooks
  class CheckUpEnabledConfigJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(server_webhook_config_id)
      server_webhook_config = ServerWebhookEvent.find_by(id: server_webhook_config_id)
      return unless server_webhook_config

      check_up(server_webhook_config)
    end

    private

    def check_up(server_webhook_config)
      # TODO: ....
      # How many events have failed recently with this config?
      # depending on this number, disable this config!
      # update notice
    end
  end
end
