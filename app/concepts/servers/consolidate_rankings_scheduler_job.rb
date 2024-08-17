# frozen_string_literal: true

module Servers
  class ConsolidateRankingsSchedulerJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(method = 'current')
      game.ids.each do |game_id|
        ConsolidateRankingsJob.perform_async(game_id, method)
      end
    end
  end
end
