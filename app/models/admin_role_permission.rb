# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_role_permissions
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  admin_permission_id :bigint           not null
#  admin_role_id       :bigint           not null
#
# Indexes
#
#  index_admin_role_permissions_on_admin_permission_id  (admin_permission_id)
#  index_admin_role_permissions_on_role_and_permission  (admin_role_id,admin_permission_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_permission_id => admin_permissions.id)
#  fk_rails_...  (admin_role_id => admin_roles.id)
#
class AdminRolePermission < ApplicationRecord
  belongs_to :admin_role
  belongs_to :admin_permission

  validates :admin_permission_id, uniqueness: { scope: :admin_role_id }
end
