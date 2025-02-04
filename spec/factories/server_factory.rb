# frozen_string_literal: true

FactoryBot.define do
  factory :server do
    game

    country_code { 'US' }
    sequence(:name) { |n| "Server #{n}" }
    sequence(:site_url) { |n| "https://server-#{n}.upper.town/" }
  end
end
