# frozen_string_literal: true

module Servers
  class DeleteArchivedWithoutVotesJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform
      archived_server_ids_without_votes.each do |server_id|
        DestroyJob.perform_async(server_id)
      end
    end

    def archived_server_ids_without_votes
      Server
        .distinct
        .archived
        .left_joins(:votes)
        .where(votes: { id: nil })
        .pluck(:id)
    end
  end
end
