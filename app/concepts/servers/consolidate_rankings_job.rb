# frozen_string_literal: true

module Servers
  class ConsolidateRankingsJob
    include Sidekiq::Job

    def perform(app_id, period, method)
      app = App.find(app_id)

      case method
      when 'all'
        ConsolidateRankings.new(app, period).process_all
      when 'current'
        ConsolidateRankings.new(app, period).process_current
      else
        raise 'Invalid method for Servers::ConsolidateRankingsJob'
      end
    end
  end
end
