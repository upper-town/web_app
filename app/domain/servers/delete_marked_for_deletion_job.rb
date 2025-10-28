# frozen_string_literal: true

module Servers
  class DeleteMarkedForDeletionJob < ApplicationJob
    queue_as "low"

    def perform
      jobs = marked_for_deletion_servers.map { DestroyJob.new(it) }
      ActiveJob.perform_all_later(jobs)
    end

    def marked_for_deletion_servers
      Server.select(:id).marked_for_deletion
    end
  end
end
