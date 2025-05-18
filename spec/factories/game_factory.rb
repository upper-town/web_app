FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    sequence(:slug) { |n| "game-#{n}" }
  end
end
