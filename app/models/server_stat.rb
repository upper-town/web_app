# frozen_string_literal: true

class ServerStat < ApplicationRecord
  ALL = "all"
  ALL_EMOJI_FLAG = "🌐"

  COUNTRY_CODES = [ALL, *Server::COUNTRY_CODES]

  belongs_to :server
  belongs_to :game

  validates :period,       presence: true, inclusion: { in: Periods::PERIODS }
  validates :country_code, presence: true, inclusion: { in: COUNTRY_CODES }
end
