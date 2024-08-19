# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_account_roles
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  admin_account_id :bigint           not null
#  admin_role_id    :bigint           not null
#
# Indexes
#
#  idx_on_admin_account_id_admin_role_id_29d5733394  (admin_account_id,admin_role_id) UNIQUE
#  index_admin_account_roles_on_admin_role_id        (admin_role_id)
#
# Foreign Keys
#
#  fk_rails_...  (admin_account_id => admin_accounts.id)
#  fk_rails_...  (admin_role_id => admin_roles.id)
#
class AdminAccountRole < ApplicationRecord
  belongs_to :admin_account
  belongs_to :admin_role

  validates :admin_role_id, uniqueness: { scope: :admin_account_id }
end
