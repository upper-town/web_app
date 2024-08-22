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
  ALL = 'all'
  ALL_EMOJI_FLAG = '🌐'

  COUNTRY_CODES = [ALL, *Server::COUNTRY_CODES]

  belongs_to :server
  belongs_to :game

  validates :period, inclusion: { in: Periods::PERIODS }
  validates :country_code, inclusion: { in: COUNTRY_CODES }
end
