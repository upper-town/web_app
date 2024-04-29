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
class AdminUserAccount < ApplicationRecord
  belongs_to :admin_user

  has_many :admin_user_account_roles, dependent: :destroy

  has_many :roles,       through: :admin_user_account_roles, source: :admin_role
  has_many :permissions, through: :roles
end
