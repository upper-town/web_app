FactoryBot.define do
  factory :admin_permission do
    sequence(:key) { |n| "admin_permission_key_#{n}" }
    description { 'Some AdminPermission' }
  end
end
