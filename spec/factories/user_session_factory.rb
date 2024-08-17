# frozen_string_literal: true

FactoryBot.define do
  factory :user_session do
    user

    sequence(:token) { |n| "user-session-token-test#{n}" }
    remote_ip { '255.255.255.255' }
    expires_at { 30.days.from_now }
  end
end
