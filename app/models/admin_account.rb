# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_accounts
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_user_id :bigint           not null
#
# Indexes
#
#  index_admin_accounts_on_admin_user_id  (admin_user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
class AdminAccount < ApplicationRecord
  belongs_to :admin_user

  has_many :admin_account_roles, dependent: :destroy

  has_many :roles,       through: :admin_account_roles, source: :admin_role
  has_many :permissions, through: :roles

  # Super Admin status can only be granted through env var.
  def super_admin?
    StringValueHelper.values_list_uniq(ENV.fetch('SUPER_ADMIN_ACCOUNT_IDS', '')).include?(id.to_s)
  end
end
