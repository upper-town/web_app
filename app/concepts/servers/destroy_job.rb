# frozen_string_literal: true

module Servers
  class DestroyJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(server_id)
      server = Server.find(server_id)

      server.stats.delete_all
      server.votes.delete_all

      server.destroy
    end
  end
end
