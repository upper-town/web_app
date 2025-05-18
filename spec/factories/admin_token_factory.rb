FactoryBot.define do
  factory :admin_token do
    admin_user

    sequence(:token_digest) { |n| Digest::SHA256.hexdigest("admin-token-#{n}-abcd") }
    token_last_four { 'abcd' }
    purpose { 'email_confirmation' }
    expires_at { 30.days.from_now }
  end
end
