# frozen_string_literal: true

module Servers
  class DestroyJob < ApplicationJob
    queue_as "low"

    def perform(server)
      server.stats.delete_all
      server.votes.delete_all
      server.destroy
    end
  end
end
