FactoryBot.define do
  factory :token do
    user

    sequence(:token_digest) { |n| Digest::SHA256.hexdigest("token-#{n}-abcd") }
    token_last_four { 'abcd' }
    purpose { 'email_confirmation' }
    expires_at { 30.days.from_now }
  end
end
