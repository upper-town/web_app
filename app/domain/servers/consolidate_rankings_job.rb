# frozen_string_literal: true

module Servers
  class ConsolidateRankingsJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(game_id, method = 'current')
      game = Game.find(game_id)

      case method
      when 'current'
        ConsolidateRankings.new(game).process_current
      when 'all'
        ConsolidateRankings.new(game).process_all
      else
        raise 'Invalid method for Servers::ConsolidateRankingsJob'
      end
    end
  end
end
