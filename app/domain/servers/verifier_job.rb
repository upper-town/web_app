# frozen_string_literal: true

module Servers
  class VerifierJob < ApplicationJob
    def perform
      Server.select(:id).not_archived.in_batches do |servers|
        jobs = servers.map { VerifyJob.new(it) }
        ActiveJob.perform_all_later(jobs)
      end
    end
  end
end
