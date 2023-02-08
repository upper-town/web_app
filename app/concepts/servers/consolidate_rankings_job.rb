# frozen_string_literal: true

module Servers
  class ConsolidateRankingsJob
    include Sidekiq::Job

    def perform(app_id, method)
      app = App.find(app_id)

      case method
      when 'current'
        ConsolidateRankings.new(app).process_current
      when 'all'
        ConsolidateRankings.new(app).process_all
      else
        raise 'Invalid method for Servers::ConsolidateRankingsJob'
      end
    end
  end
end
