class ServerStat < ApplicationRecord
  ALL = "all"
  ALL_EMOJI_FLAG = "🌐"

  COUNTRY_CODES = [ ALL, *Server::COUNTRY_CODES ]

  belongs_to :server
  belongs_to :game

  validates :period, inclusion: { in: Periods::PERIODS }, presence: true
  validates :country_code, inclusion: { in: COUNTRY_CODES }, presence: true
end
