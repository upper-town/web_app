FactoryBot.define do
  factory :feature_flag do
    sequence(:name) { |n| "someting#{n}" }
    value { "true" }
  end
end
