# frozen_string_literal: true

module ServerWebhooks
  module CreateEvents
    class ServerVoteCreatedJob < ApplicationJob
      # TODO: rewrite lock: :while_executing)

      EVENT_TYPE = 'server_vote.created'

      def perform(server_vote)
        server_webhook_events = create_server_webhook_events(server_vote)

        server_webhook_events.each do |server_webhook_event|
          PublishEventJob.perform_later(server_webhook_event)
        end
      end

      private

      def create_server_webhook_events(server_vote)
        configs = ServerWebhookConfig.for(server_vote.server_id, EVENT_TYPE)
        return [] if configs.empty?

        payload = EventPayloads::ServerVoteCreated.call(server_vote)
        server_webhook_events = []

        ActiveRecord::Base.transaction do
          configs.each do |config|
            server_webhook_events << ServerWebhookEvent.create!(
              type:      EVENT_TYPE,
              config:    config,
              payload:   payload,
              status:    ServerWebhookEvent::PENDING,
              server_id: server_vote.server_id
            )
          end
        end

        server_webhook_events
      end
    end
  end
end
