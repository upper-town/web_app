# frozen_string_literal: true

FactoryBot.define do
  factory :server_stat do
    server
    game

    country_code { 'US' }
    period { 'year' }
    reference_date { '2024-01-01' }
  end
end
