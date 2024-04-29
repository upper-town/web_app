# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_user_accounts
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_user_id :bigint           not null
#
# Indexes
#
#  index_admin_user_accounts_on_admin_user_id  (admin_user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
FactoryBot.define do
  factory :admin_user_account do
    admin_user
  end
end
