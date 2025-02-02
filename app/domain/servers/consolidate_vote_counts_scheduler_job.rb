# frozen_string_literal: true

module Servers
  class ConsolidateVoteCountsSchedulerJob
    include Sidekiq::Job

    METHODS = ['current', 'all']

    sidekiq_options(lock: :while_executing)

    def perform(method = 'current')
      raise 'Invalid method for Servers::ConsolidateVoteCountsSchedulerJob' unless METHODS.include?(method)

      Server.ids.each do |server_id|
        ConsolidateVoteCountsJob.perform_async(server_id, method)
      end
    end
  end
end
