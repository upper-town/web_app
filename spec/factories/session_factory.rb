# frozen_string_literal: true

# == Schema Information
#
# Table name: sessions
#
#  id              :bigint           not null, primary key
#  expires_at      :datetime         not null
#  remote_ip       :string           not null
#  token_digest    :string           not null
#  token_last_four :string           not null
#  user_agent      :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_sessions_on_token_digest  (token_digest) UNIQUE
#  index_sessions_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :session do
    user

    sequence(:token_digest) { |n| Digest::SHA256.hexdigest("token-#{n}-abcd") }
    token_last_four { 'abcd' }
    remote_ip { '255.255.255.255' }
    expires_at { 30.days.from_now }
  end
end
