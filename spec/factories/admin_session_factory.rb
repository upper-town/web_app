# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_sessions
#
#  id            :bigint           not null, primary key
#  expires_at    :datetime         not null
#  remote_ip     :string           not null
#  token         :string           not null
#  user_agent    :string           default(""), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_user_id :bigint           not null
#
# Indexes
#
#  index_admin_sessions_on_admin_user_id_and_token  (admin_user_id,token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
FactoryBot.define do
  factory :admin_session do
    admin_user

    sequence(:token) { |n| "admin-session-#{n}" }
    remote_ip { '255.255.255.255' }
    expires_at { 30.days.from_now }
  end
end
