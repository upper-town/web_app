# frozen_string_literal: true

class ServerStat < ApplicationRecord
  belongs_to :server
  belongs_to :game

  validates :period, presence: true, inclusion: { in: Periods::PERIODS }
end
