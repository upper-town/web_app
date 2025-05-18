FactoryBot.define do
  factory :feature_flag do
    sequence(:name) { |n| "feature_flag_#{n}" }
    value { 'true' }
  end
end
