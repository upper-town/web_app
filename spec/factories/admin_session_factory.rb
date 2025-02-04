# frozen_string_literal: true

FactoryBot.define do
  factory :admin_session do
    admin_user

    sequence(:token_digest) { |n| Digest::SHA256.hexdigest("admin-token-#{n}-abcd") }
    token_last_four { 'abcd' }
    remote_ip { '255.255.255.255' }
    expires_at { 30.days.from_now }
  end
end
