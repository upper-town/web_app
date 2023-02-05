# frozen_string_literal: true

module Servers
  class ConsolidateRankingsSchedulerJob
    include Sidekiq::Job

    def perform(method = 'current')
      App.ids.each do |app_id|
        ConsolidateRankingsJob.perform_async(app_id, method)
      end
    end
  end
end
