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
require 'rails_helper'

RSpec.describe AdminRolePermission do
  describe 'associations' do
    it 'belongs to admin_role' do
      admin_role_permission = create(:admin_role_permission)

      expect(admin_role_permission.admin_role).to be_present
    end

    it 'belongs to admin_permission' do
      admin_role_permission = create(:admin_role_permission)

      expect(admin_role_permission.admin_permission).to be_present
    end
  end

  describe 'validations' do
    it 'validates admin_permission_id scoped to admin_role_id' do
      admin_role = create(:admin_role)
      admin_permission = create(:admin_permission)
      existing_admin_role_permission = create(
        :admin_role_permission,
        admin_role: admin_role,
        admin_permission: admin_permission
      )
      admin_role_permission = build(
        :admin_role_permission,
        admin_role: admin_role,
        admin_permission: admin_permission
      )

      admin_role_permission.validate

      expect(admin_role_permission.errors.of_kind?(:admin_permission_id, :taken)).to be(true)

      existing_admin_role_permission.destroy!
      admin_role_permission.validate

      expect(admin_role_permission.errors.key?(:admin_permission_id)).to be(false)
    end
  end
end
