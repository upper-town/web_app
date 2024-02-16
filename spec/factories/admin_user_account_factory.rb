# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_user_accounts
#
#  id            :bigint           not null, primary key
#  uuid          :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_user_id :bigint           not null
#
# Indexes
#
#  index_admin_user_accounts_on_admin_user_id  (admin_user_id) UNIQUE
#  index_admin_user_accounts_on_uuid           (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
FactoryBot.define do
  factory :admin_user_account do
    uuid { SecureRandom.uuid }
    admin_user
  end
end
