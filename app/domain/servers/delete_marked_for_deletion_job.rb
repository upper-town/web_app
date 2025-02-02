# frozen_string_literal: true

module Servers
  class DeleteMarkedForDeletionJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform
      marked_for_deletion_server_ids.each do |server_id|
        DestroyJob.perform_async(server_id)
      end
    end

    def marked_for_deletion_server_ids
      Server.marked_for_deletion.pluck(:id)
    end
  end
end
