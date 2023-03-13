# frozen_string_literal: true

# == Schema Information
#
# Table name: apps
#
#  id          :bigint           not null, primary key
#  description :string           default(""), not null
#  info        :text             default(""), not null
#  type        :string           not null
#  name        :string           not null
#  site_url    :string           default(""), not null
#  slug        :string           not null
#  uuid        :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_apps_on_type  (type)
#  index_apps_on_name  (name) UNIQUE
#  index_apps_on_slug  (slug) UNIQUE
#  index_apps_on_uuid  (uuid) UNIQUE
#
class App < ApplicationRecord
  include ShortUuidForModel

  GAME = 'game'
  TYPES = [GAME].freeze
  TYPE_OPTIONS = [
    ['Game', GAME],
  ].freeze

  validates :type, inclusion: { in: TYPES }

  has_many :servers, dependent: :destroy
  has_many :server_votes, dependent: :destroy
  has_many :server_stats, dependent: :destroy
end
