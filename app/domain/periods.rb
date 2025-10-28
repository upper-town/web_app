# frozen_string_literal: true

module Periods
  YEAR  = "year"
  MONTH = "month"
  WEEK  = "week"

  PERIODS = [YEAR, MONTH, WEEK]
  PERIOD_OPTIONS = [
    ["Year",  YEAR],
    ["Month", MONTH],
    ["Week",  WEEK]
  ]

  extend self

  def min_past_time
    Time.iso8601(ENV.fetch("PERIODS_MIN_PAST_TIME"))
  end

  def reference_date_for(period, current_time)
    current_time = current_time.utc

    case period
    when YEAR  then current_time.end_of_year.to_date
    when MONTH then current_time.end_of_month.to_date
    when WEEK  then current_time.end_of_week.to_date
    else
      raise "Invalid period for Periods.reference_date_for"
    end
  end

  def reference_range_for(period, current_time)
    current_time = current_time.utc

    case period
    when YEAR  then current_time.all_year
    when MONTH then current_time.all_month
    when WEEK  then current_time.all_week
    else
      raise "Invalid period for Periods.reference_range_for"
    end
  end

  def next_time_for(period, current_time)
    current_time = current_time.utc

    case period
    when YEAR  then current_time.next_year
    when MONTH then current_time.next_month
    when WEEK  then current_time.next_week
    else
      raise "Invalid period for Periods.next_time_for"
    end
  end

  def loop_through(period, past_time = nil, current_time = nil)
    past_time =
      if past_time.nil?
        Time.current.utc
      elsif past_time < min_past_time
        min_past_time
      else
        past_time.utc
      end

    current_time = current_time.nil? ? past_time : current_time.utc

    if past_time > current_time
      raise "Invalid past_time or current_time for Periods.loop_through"
    end

    past_time = past_time.beginning_of_day
    current_time = current_time.end_of_day

    while past_time <= current_time
      reference_date = reference_date_for(period, past_time)
      reference_range = reference_range_for(period, past_time)

      yield reference_date, reference_range

      past_time = next_time_for(period, past_time)
    end
  end
end
