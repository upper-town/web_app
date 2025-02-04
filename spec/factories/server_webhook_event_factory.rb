# frozen_string_literal: true

FactoryBot.define do
  factory :server_webhook_event do
    server

    type { 'test.event' }
    payload { {} }
    status { ServerWebhookEvent::PENDING }
  end
end
