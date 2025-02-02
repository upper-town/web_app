# frozen_string_literal: true

module Servers
  class ConsolidateRankingsSchedulerJob
    include Sidekiq::Job

    METHODS = ['current', 'all']

    sidekiq_options(lock: :while_executing)

    def perform(method = 'current')
      raise 'Invalid method for Servers::ConsolidateRankingsSchedulerJob' unless METHODS.include?(method)

      Game.ids.each do |game_id|
        ConsolidateRankingsJob.perform_async(game_id, method)
      end
    end
  end
end
