# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_tokens
#
#  id              :bigint           not null, primary key
#  data            :jsonb            not null
#  expires_at      :datetime         not null
#  purpose         :string           not null
#  token_digest    :string           not null
#  token_last_four :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin_user_id   :bigint           not null
#
# Indexes
#
#  index_admin_tokens_on_admin_user_id  (admin_user_id)
#  index_admin_tokens_on_expires_at     (expires_at)
#  index_admin_tokens_on_purpose        (purpose)
#  index_admin_tokens_on_token_digest   (token_digest) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
FactoryBot.define do
  factory :admin_token do
    admin_user

    sequence(:token_digest) { |n| Digest::SHA256.hexdigest("admin-token-#{n}-abcd") }
    token_last_four { 'abcd' }
    purpose { 'email_confirmation' }
    expires_at { 30.days.from_now }
  end
end
