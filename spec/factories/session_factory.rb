# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    user

    sequence(:token_digest) { |n| Digest::SHA256.hexdigest("token-#{n}-abcd") }
    token_last_four { 'abcd' }
    remote_ip { '255.255.255.255' }
    expires_at { 30.days.from_now }
  end
end
