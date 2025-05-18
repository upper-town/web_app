FactoryBot.define do
  factory :server_vote do
    server
    game

    country_code { 'US' }
  end
end
