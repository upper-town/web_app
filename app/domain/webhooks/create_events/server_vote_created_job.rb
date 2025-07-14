# frozen_string_literal: true

module Webhooks
  module CreateEvents
    class ServerVoteCreatedJob < ApplicationJob
      # TODO: rewrite lock: :while_executing)

      EVENT_TYPE = "server_vote.created"

      def perform(server_vote)
        webhook_events = create_webhook_events(server_vote)

        webhook_events.each do |webhook_event|
          PublishEventJob.perform_later(webhook_event)
        end
      end

      private

      def create_webhook_events(server_vote)
        configs = WebhookConfig.for(server_vote.server_id, EVENT_TYPE)
        return [] if configs.empty?

        data = EventData::ServerVoteCreated.call(server_vote)
        webhook_events = []

        ActiveRecord::Base.transaction do
          configs.each do |config|
            webhook_events << WebhookEvent.create!(
              type: EVENT_TYPE,
              config:,
              data:,
              status: WebhookEvent::PENDING
            )
          end
        end

        webhook_events
      end
    end
  end
end
