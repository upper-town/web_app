# frozen_string_literal: true

module Servers
  class DeleteArchivedJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform
      server_ids = archived_server_ids_without_votes

      ServerStat.where(server_id: server_ids).delete_all
      ServerUserAccount.where(server_id: server_ids).delete_all

      Server.where(server_id: server_ids).destroy_all
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
