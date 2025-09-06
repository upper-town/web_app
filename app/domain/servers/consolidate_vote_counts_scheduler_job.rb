# frozen_string_literal: true

module Servers
  class ConsolidateVoteCountsSchedulerJob < ApplicationJob
    limits_concurrency key: ->(method) { method }

    METHODS = ["current", "all"]

    def perform(method = "current")
      raise "Invalid method for Servers::ConsolidateVoteCountsSchedulerJob" unless METHODS.include?(method)

      Server.select(:id).find_each do |server|
        ConsolidateVoteCountsJob.perform_later(server, method)
      end
    end
  end
end
