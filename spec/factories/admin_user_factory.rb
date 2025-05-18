FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin.user.#{n}@upper.town" }
    password { 'testpass' }
  end
end
