# frozen_string_literal: true

module Servers
  class StatsPreviousConsolidatorJob < ApplicationJob
    queue_as "low"

    def perform(period)
      StatsConsolidator.call([period], current_time(period))
    end

    private

    def current_time(period)
      case period
      when Periods::WEEK  then 1.week.ago.end_of_week
      when Periods::MONTH then 1.month.ago.end_of_month
      when Periods::YEAR  then 1.year.ago.end_of_year
      else
        raise "#{self.class.name}: invalid period: #{period}"
      end
    end
  end
end
