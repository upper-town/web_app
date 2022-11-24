FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin.user.#{n}@example.com" }
    password { 'testpass' }
  end
end
