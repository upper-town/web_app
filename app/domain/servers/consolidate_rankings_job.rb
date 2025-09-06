# frozen_string_literal: true

module Servers
  class ConsolidateRankingsJob < ApplicationJob
    limits_concurrency key: ->(game, *) { game }

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
