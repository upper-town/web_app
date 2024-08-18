# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user_session do
    admin_user

    sequence(:token) { |n| "user-session-token-test#{n}" }
    remote_ip { '255.255.255.255' }
    expires_at { 30.days.from_now }
  end
end
