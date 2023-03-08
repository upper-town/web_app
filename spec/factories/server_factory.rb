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
FactoryBot.define do
  factory :server do
    app

    uuid { SecureRandom.uuid }
    country_code { 'US' }
    sequence(:name) { |n| "Server #{n}" }
    sequence(:site_url) { |n| "https://server-#{n}.example.com/" }
  end
end
