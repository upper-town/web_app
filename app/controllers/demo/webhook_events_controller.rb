# frozen_string_literal: true

module Demo
  class WebhookEventsController < ApplicationApiController
    def create
      case rand(1..10)
      when 1
        case rand(1..2)
        when 1 then head :not_found
        when 2 then head :internal_server_error
        end
      else
        case rand(1..10)
        when 1 then perform(delay: 90)
        else
          perform
        end
      end
    end

    private

    def perform(delay: 0)
      webhook_request = Webhooks::Request.new(request)

      if webhook_request.valid?
        sleep(delay)
        DemoWebhookEvent.insert_all(webhook_request.webhook_event_hashes)

        head :ok
      else
        head :not_found
      end
    end
  end
end
