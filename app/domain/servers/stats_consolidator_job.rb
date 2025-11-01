# frozen_string_literal: true

module Servers
  class StatsConsolidatorJob < ApplicationPollingJob
    limits_concurrency key: "0", on_conflict: :discard

    def perform
      StatsConsolidator.call
    end
  end
end
