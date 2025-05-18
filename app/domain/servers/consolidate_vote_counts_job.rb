module Servers
  class ConsolidateVoteCountsJob < ApplicationJob
    # TODO: rewrite lock: :while_executing)

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
