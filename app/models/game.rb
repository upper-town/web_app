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

  normalizes :name, with: ->(str) { str.squish }
  normalizes :description, with: ->(str) { str.squish }
  normalizes :info, with: ->(str) { str.strip }

  validates :name, length: { minimum: 3, maximum: 255 }, presence: true
  validates :description, length: { maximum: 1_000 }
  validates :info, length: { maximum: 1_000 }
  validates :site_url, length: { minimum: 3, maximum: 255 }, allow_blank: true

  validate do |record|
    SiteUrlRecordValidator.new(record).validate
  end
end
