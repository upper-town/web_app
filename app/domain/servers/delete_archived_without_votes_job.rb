# frozen_string_literal: true

module Servers
  class DeleteArchivedWithoutVotesJob < ApplicationJob
    queue_as "low"
    # TODO: rewrite lock: :while_executing)

    def perform
      archived_servers_without_votes.each do |server|
        DestroyJob.perform_later(server)
      end
    end

    def archived_servers_without_votes
      Server
        .select(:id)
        .archived
        .where.missing(:votes)
        .distinct
    end
  end
end
