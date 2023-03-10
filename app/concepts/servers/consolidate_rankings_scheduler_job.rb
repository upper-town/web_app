# frozen_string_literal: true

module Servers
  class ConsolidateRankingsSchedulerJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(method = 'current')
      App.ids.each do |app_id|
        ConsolidateRankingsJob.perform_async(app_id, method)
      end
    end
  end
end
