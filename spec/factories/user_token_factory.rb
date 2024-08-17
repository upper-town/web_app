# frozen_string_literal: true

FactoryBot.define do
  factory :user_token do
    user

    sequence(:token) { |n| "user-token-token-test#{n}" }
    purpose { 'email_confirmation' }
    expires_at { 30.days.from_now }
  end
end
