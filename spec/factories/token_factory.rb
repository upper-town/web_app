# frozen_string_literal: true

# == Schema Information
#
# Table name: tokens
#
#  id              :bigint           not null, primary key
#  data            :jsonb            not null
#  expires_at      :datetime         not null
#  purpose         :string           not null
#  token_digest    :string           not null
#  token_last_four :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_tokens_on_expires_at    (expires_at)
#  index_tokens_on_purpose       (purpose)
#  index_tokens_on_token_digest  (token_digest) UNIQUE
#  index_tokens_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :token do
    user

    sequence(:token_digest) { |n| Digest::SHA256.hexdigest("token-#{n}-abcd") }
    token_last_four { 'abcd' }
    purpose { 'email_confirmation' }
    expires_at { 30.days.from_now }
  end
end
