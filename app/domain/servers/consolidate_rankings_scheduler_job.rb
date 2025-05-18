module Servers
  class ConsolidateRankingsSchedulerJob < ApplicationJob
    # TODO: rewrite lock: :while_executing)

    METHODS = [ "current", "all" ]

    def perform(method = "current")
      raise "Invalid method for Servers::ConsolidateRankingsSchedulerJob" unless METHODS.include?(method)

      Game.select(:id).find_each do |game|
        ConsolidateRankingsJob.perform_later(game, method)
      end
    end
  end
end
