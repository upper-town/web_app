# frozen_string_literal: true

module Servers
  class ConsolidateVoteCountsJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing, lock_args_method: :lock_args)

    def self.lock_args(args)
      [args[0], args[1]]
    end

    def perform(server_id, method, schedule_consolidate_rankings_job = false)
      server = Server.find(server_id)

      case method
      when 'current'
        ConsolidateVoteCounts.new(server).process_current
      when 'all'
        ConsolidateVoteCounts.new(server).process_all
      else
        raise 'Invalid method for Servers::ConsolidateVoteCountsJob'
      end

      if schedule_consolidate_rankings_job
        ConsolidateRankingsJob.set(queue: 'critical').perform_async(server.app_id, method)
      end
    end
  end
end
