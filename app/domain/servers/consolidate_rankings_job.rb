# frozen_string_literal: true

module Servers
  class ConsolidateRankingsJob < ApplicationJob
    # TODO: rewrite lock: :while_executing)

    def perform(game, method = "current")
      case method
      when "current"
        ConsolidateRankings.new(game).process_current
      when "all"
        ConsolidateRankings.new(game).process_all
      else
        raise "Invalid method for Servers::ConsolidateRankingsJob"
      end
    end
  end
end
