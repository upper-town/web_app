# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user_token do
    admin_user

    sequence(:token) { |n| "admin-user-token-token-test#{n}" }
    purpose { 'email_confirmation' }
    expires_at { 30.days.from_now }
  end
end
