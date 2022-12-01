# frozen_string_literal: true

FactoryBot.define do
  factory :server do
    uuid { SecureRandom.uuid }
    sequence(:name) { |n| "Server #{n}" }
    sequence(:site_url) { |n| "https://server-#{n}.example.com/" }
  end
end
