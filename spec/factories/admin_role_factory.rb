# frozen_string_literal: true

FactoryBot.define do
  factory :admin_role do
    sequence(:key) { |n| "admin_role_key_#{n}" }
    description { 'AdminRole' }
  end
end
