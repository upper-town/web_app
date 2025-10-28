# frozen_string_literal: true

module Servers
  class DeleteArchivedWithoutVotesJob < ApplicationJob
    queue_as "low"

    def perform
      jobs = archived_servers_without_votes.map { DestroyJob.new(it) }
      ActiveJob.perform_all_later(jobs)
    end

    def archived_servers_without_votes
      Server
        .distinct
        .select(:id)
        .archived
        .where.missing(:votes)
    end
  end
end
