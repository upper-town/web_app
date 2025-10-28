# frozen_string_literal: true

module Servers
  class StatsConsolidatorJob < ApplicationPollingJob
    def perform
      StatsConsolidator.call
    end
  end
end
