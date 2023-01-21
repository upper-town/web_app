# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id               :bigint           not null, primary key
#  banner_image_url :string           default(""), not null
#  country_code     :string           not null
#  description      :string           default(""), not null
#  info             :text             default(""), not null
#  name             :string           not null
#  site_url         :string           default(""), not null
#  uuid             :uuid             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  app_id           :bigint           not null
#
# Indexes
#
#  index_servers_on_app_id           (app_id)
#  index_servers_on_country_code     (country_code)
#  index_servers_on_name_and_app_id  (name,app_id) UNIQUE
#  index_servers_on_uuid             (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_id => apps.id)
#
class Server < ApplicationRecord
  COUNTRY_CODES = ISO3166::Country.codes

  validates :country_code, inclusion: { in: COUNTRY_CODES }

  belongs_to :app

  has_many :votes, class_name: 'ServerVote', dependent: :destroy
  has_many :stats, class_name: 'ServerStat', dependent: :destroy
end
