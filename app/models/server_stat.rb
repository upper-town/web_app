# frozen_string_literal: true

# == Schema Information
#
# Table name: server_stats
#
#  id                             :bigint           not null, primary key
#  country_code                   :string           not null
#  period                         :string           not null
#  ranking_number                 :bigint
#  ranking_number_consolidated_at :datetime
#  reference_date                 :date             not null
#  vote_count                     :bigint           default(0), not null
#  vote_count_consolidated_at     :datetime
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  game_id                        :bigint           not null
#  server_id                      :bigint           not null
#
# Indexes
#
#  index_server_stats_on_period_reference_app_country_server  (period,reference_date,game_id,country_code,server_id) UNIQUE
#  index_server_stats_on_server_id                            (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (server_id => servers.id)
#
class ServerStat < ApplicationRecord
  YEAR  = 'year'
  MONTH = 'month'
  WEEK  = 'week'
  PERIODS = [YEAR, MONTH, WEEK]
  PERIOD_OPTIONS = [
    ['Year',  YEAR],
    ['Month', MONTH],
    ['Week',  WEEK]
  ]

  ALL = 'all'
  ALL_EMOJI_FLAG = '🌐'
  COUNTRY_CODES = [ALL, *Server::COUNTRY_CODES]

  belongs_to :server
  belongs_to :game

  validates :period, inclusion: { in: PERIODS }
  validates :country_code, inclusion: { in: COUNTRY_CODES }

  def self.min_past_time
    Time.iso8601(ENV.fetch('PERIODS_MIN_PAST_TIME'))
  end

  def self.reference_date_for(period, current_time)
    current_time = current_time.utc

    case period
    when ServerStat::YEAR  then current_time.end_of_year.to_date
    when ServerStat::MONTH then current_time.end_of_month.to_date
    when ServerStat::WEEK  then current_time.end_of_week.to_date
    else
      raise 'Invalid period for ServerStat.reference_date_for'
    end
  end

  def self.reference_range_for(period, current_time)
    current_time = current_time.utc

    case period
    when YEAR  then current_time.all_year
    when MONTH then current_time.all_month
    when WEEK  then current_time.all_week
    else
      raise 'Invalid period for ServerStat.reference_range_for'
    end
  end

  def self.next_time_for(period, current_time)
    current_time = current_time.utc

    case period
    when YEAR  then current_time.next_year
    when MONTH then current_time.next_month
    when WEEK  then current_time.next_week
    else
      raise 'Invalid period for ServerStat.next_time_for'
    end
  end

  def self.loop_through(period, past_time = nil, current_time = nil)
    past_time = (past_time.nil? || past_time < min_past_time) ? min_past_time : past_time.utc
    current_time = current_time.nil? ? Time.current.utc : current_time.utc

    if past_time > current_time
      raise 'Invalid past_time or current_time for ServerStat.loop_through'
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
