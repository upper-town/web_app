require 'rails_helper'

RSpec.describe AdminPermission do
  describe 'associations' do
    it 'has many admin_role_permissions' do
      admin_permission = create(:admin_permission)
      admin_role_permission1 = create(:admin_role_permission, admin_permission: admin_permission)
      admin_role_permission2 = create(:admin_role_permission, admin_permission: admin_permission)

      expect(admin_permission.admin_role_permissions).to contain_exactly(
        admin_role_permission1, admin_role_permission2
      )
      admin_permission.destroy!
      expect { admin_role_permission1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { admin_role_permission2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many roles through admin_role_permissions' do
      admin_permission = create(:admin_permission)
      admin_role_permission1 = create(:admin_role_permission, admin_permission: admin_permission)
      admin_role_permission2 = create(:admin_role_permission, admin_permission: admin_permission)

      expect(admin_permission.roles).to contain_exactly(
        admin_role_permission1.admin_role, admin_role_permission2.admin_role
      )
    end

    it 'has many distinct accounts through roles' do
      admin_account1 = create(:admin_account)
      admin_account2 = create(:admin_account)
      admin_role1 = create(:admin_role)
      admin_role2 = create(:admin_role)
      admin_role3 = create(:admin_role)
      create(:admin_account_role, admin_account: admin_account1, admin_role: admin_role1)
      create(:admin_account_role, admin_account: admin_account1, admin_role: admin_role2)
      create(:admin_account_role, admin_account: admin_account2, admin_role: admin_role3)
      admin_permission = create(:admin_permission)
      create(:admin_role_permission, admin_role: admin_role1, admin_permission: admin_permission)
      create(:admin_role_permission, admin_role: admin_role2, admin_permission: admin_permission)
      create(:admin_role_permission, admin_role: admin_role3, admin_permission: admin_permission)

      expect(admin_permission.accounts).to contain_exactly(
        admin_account1, admin_account2
      )
    end
  end

  describe 'normalizations' do
    it 'normalizes key' do
      admin_permission = create(:admin_permission, key: "\n\t Admin  Permission Key \n")

      expect(admin_permission.key).to eq('admin_permission_key')
    end

    it 'normalizes description' do
      admin_permission = create(:admin_permission, description: "\n\t AdminPermission  description \n")

      expect(admin_permission.description).to eq('AdminPermission description')
    end
  end

  describe 'validations' do
    it 'validates key' do
      admin_permission = build(:admin_permission, key: ' ')
      admin_permission.validate
      expect(admin_permission.errors.of_kind?(:key, :blank)).to be(true)

      another_admin_permission = create(:admin_permission, key: 'Admin_Permission_Key')

      admin_permission = build(:admin_permission, key: 'admin_permission_key')
      admin_permission.validate
      expect(admin_permission.errors.of_kind?(:key, :taken)).to be(true)

      another_admin_permission.destroy!

      admin_permission = build(:admin_permission, key: 'admin_permission_key')
      admin_permission.validate
      expect(admin_permission.errors.key?(:key)).to be(false)
    end

    it 'validates description' do
      admin_permission = build(:admin_permission, description: ' ')
      admin_permission.validate
      expect(admin_permission.errors.of_kind?(:description, :blank)).to be(true)

      admin_permission = build(:admin_permission, description: 'AdminPermission description')
      admin_permission.validate
      expect(admin_permission.errors.key?(:description)).to be(false)
    end
  end
end
