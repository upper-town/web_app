FactoryBot.define do
  factory :user do
    uuid { SecureRandom.uuid }
    sequence(:email) { |n| "user.#{n}@example.com" }
    password { 'testpass' }
  end
end
