# frozen_string_literal: true

module Servers
  class ConsolidateVoteCountsJob
    include Sidekiq::Job

    sidekiq_options(lock: :while_executing)

    def perform(server_id, method = 'current')
      server = Server.find(server_id)

      case method
      when 'current'
        ConsolidateVoteCounts.new(server).process_current
      when 'all'
        ConsolidateVoteCounts.new(server).process_all
      else
        raise 'Invalid method for Servers::ConsolidateVoteCountsJob'
      end
    end
  end
end
