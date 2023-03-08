# frozen_string_literal: true

# == Schema Information
#
# Table name: apps
#
#  id          :bigint           not null, primary key
#  description :string           default(""), not null
#  info        :text             default(""), not null
#  kind        :string           not null
#  name        :string           not null
#  site_url    :string           default(""), not null
#  slug        :string           not null
#  uuid        :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_apps_on_kind  (kind)
#  index_apps_on_name  (name) UNIQUE
#  index_apps_on_slug  (slug) UNIQUE
#  index_apps_on_uuid  (uuid) UNIQUE
#
FactoryBot.define do
  factory :app do
    uuid { SecureRandom.uuid }
    kind { App::GAME }
    sequence(:name) { |n| "App #{n}" }
    sequence(:slug) { |n| "app-#{n}" }
  end
end
