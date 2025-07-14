# frozen_string_literal: true

class Game < ApplicationRecord
  has_many :servers, dependent: :destroy
  has_many :server_votes, dependent: :destroy
  has_many :server_stats, dependent: :destroy

  normalizes :name,        with: NormalizeName
  normalizes :description, with: NormalizeDescription
  normalizes :info,        with: NormalizeInfo

  validates :name, length: { minimum: 3, maximum: 255 }, presence: true
  validates :description, length: { maximum: 1_000 }
  validates :info, length: { maximum: 1_000 }
  validates :site_url, allow_blank: true, length: { minimum: 3, maximum: 255 }, site_url: true
end
