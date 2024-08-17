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
FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game Test #{n}" }
    sequence(:slug) { |n| "game-test-#{n}" }
  end
end
