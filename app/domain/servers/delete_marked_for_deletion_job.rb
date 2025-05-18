module Servers
  class DeleteMarkedForDeletionJob < ApplicationJob
    queue_as "low"
    # TODO: rewrite lock: :while_executing)

    def perform
      marked_for_deletion_servers.each do |server|
        DestroyJob.perform_later(server)
      end
    end

    def marked_for_deletion_servers
      Server.select(:id).marked_for_deletion
    end
  end
end
