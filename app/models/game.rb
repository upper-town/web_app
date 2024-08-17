# frozen_string_literal: true

# == Schema Information
#
# Table name: games
#
#  id          :bigint           not null, primary key
#  description :string           default(""), not null
#  info        :text             default(""), not null
#  name        :string           not null
#  site_url    :string           default(""), not null
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_games_on_name  (name) UNIQUE
#  index_games_on_slug  (slug) UNIQUE
#
class Game < ApplicationRecord
  has_many :servers, dependent: :destroy
  has_many :server_votes, dependent: :destroy
  has_many :server_stats, dependent: :destroy
end
