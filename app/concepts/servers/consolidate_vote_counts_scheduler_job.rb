# frozen_string_literal: true

module Servers
  class ConsolidateVoteCountsSchedulerJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(method = 'current')
      Server.ids.each do |server_id|
        ConsolidateVoteCountsJob.perform_async(server_id, method)
      end
    end
  end
end
