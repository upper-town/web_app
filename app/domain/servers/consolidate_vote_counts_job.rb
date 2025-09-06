# frozen_string_literal: true

module Servers
  class ConsolidateVoteCountsJob < ApplicationJob
    limits_concurrency key: ->(server, *) { server }

    def perform(server, method = "current")
      case method
      when "current"
        ConsolidateVoteCounts.new(server).process_current
      when "all"
        ConsolidateVoteCounts.new(server).process_all
      else
        raise "Invalid method for Servers::ConsolidateVoteCountsJob"
      end
    end
  end
end
