# frozen_string_literal: true

module Servers
  class ConsolidateVoteCountsJob
    include Sidekiq::Job

    def perform(server_id, method)
      server = Server.find(server_id)

      case method
      when 'all'
        ConsolidateVoteCounts.new(server).process_all
      when 'current'
        ConsolidateVoteCounts.new(server).process_current
      else
        raise 'Invalid method for Servers::ConsolidateVoteCountsJob'
      end
    end
  end
end
