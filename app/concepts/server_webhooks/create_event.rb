# frozen_string_literal: true

module ServerWebhooks
  class CreateEvent
    attr_reader :server, :event_type, :record_id

    def initialize(server, event_type, record_id = nil)
      @server = server
      @event_type = event_type
      @record_id = record_id
    end

    def call
      create_event(build_payload)
    end

    private

    def build_payload
      case event_type
      when ServerWebhookEvent::SERVER_VOTES_CREATE
        build_payload_server_votes_create(record_id)
      else
        raise 'Unknown event_type for ServerWebhooks::CreateEvent'
      end
    end

    def build_payload_server_votes_create(server_vote_id)
      server_vote = ServerVote.find(server_vote_id)
      EventPayloads::ServerVotesCreate.new(server_vote).call
    end

    def create_event(payload)
      ServerWebhookEvent.create!(
        server:  server,
        type:    event_type,
        status:  ServerWebhookEvent::PENDING,
        payload: payload,
      )
    end
  end
end
