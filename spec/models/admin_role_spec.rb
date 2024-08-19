# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_roles
#
#  id          :bigint           not null, primary key
#  description :string           default(""), not null
#  key         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_admin_roles_on_key  (key) UNIQUE
#
require 'rails_helper'

RSpec.describe AdminRole do
  describe 'associations' do
    it 'has many admin_account_roles' do
      admin_role = create(:admin_role)
      admin_account_role1 = create(:admin_account_role, admin_role: admin_role)
      admin_account_role2 = create(:admin_account_role, admin_role: admin_role)

      expect(admin_role.admin_account_roles).to contain_exactly(
        admin_account_role1, admin_account_role2
      )
      admin_role.destroy!
      expect { admin_account_role1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { admin_account_role2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many admin_role_permissions' do
      admin_role = create(:admin_role)
      admin_role_permission1 = create(:admin_role_permission, admin_role: admin_role)
      admin_role_permission2 = create(:admin_role_permission, admin_role: admin_role)

      expect(admin_role.admin_role_permissions).to contain_exactly(
        admin_role_permission1, admin_role_permission2
      )
      admin_role.destroy!
      expect { admin_role_permission1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { admin_role_permission2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many accounts through admin_account_roles' do
      admin_role = create(:admin_role)
      admin_account_role1 = create(:admin_account_role, admin_role: admin_role)
      admin_account_role2 = create(:admin_account_role, admin_role: admin_role)

      expect(admin_role.accounts).to contain_exactly(
        admin_account_role1.admin_account, admin_account_role2.admin_account
      )
    end

    it 'has many permissions through admin_role_permissions' do
      admin_role = create(:admin_role)
      admin_role_permission1 = create(:admin_role_permission, admin_role: admin_role)
      admin_role_permission2 = create(:admin_role_permission, admin_role: admin_role)

      expect(admin_role.permissions).to contain_exactly(
        admin_role_permission1.admin_permission, admin_role_permission2.admin_permission
      )
    end
  end

  describe 'normalizations' do
    it 'normalizes key' do
      admin_role = create(:admin_role, key: "\n\t Admin  Role Key\n")

      expect(admin_role.key).to eq('admin_role_key')
    end

    it 'normalizes description' do
      admin_role = create(:admin_role, description: "\n\t AdminRole  description \n")

      expect(admin_role.description).to eq('AdminRole description')
    end
  end

  describe 'validations' do
    it 'validates key' do
      admin_role = build(:admin_role, key: ' ')
      admin_role.validate
      expect(admin_role.errors.of_kind?(:key, :blank)).to be(true)

      another_admin_role = create(:admin_role, key: 'Admin_Role_Key')

      admin_role = build(:admin_role, key: 'admin_role_key')
      admin_role.validate
      expect(admin_role.errors.of_kind?(:key, :taken)).to be(true)

      another_admin_role.destroy!

      admin_role = build(:admin_role, key: 'admin_role_key')
      admin_role.validate
      expect(admin_role.errors.key?(:key)).to be(false)
    end

    it 'validates description' do
      admin_role = build(:admin_role, description: ' ')
      admin_role.validate
      expect(admin_role.errors.of_kind?(:description, :blank)).to be(true)

      admin_role = build(:admin_role, description: 'AdminRole description')
      admin_role.validate
      expect(admin_role.errors.key?(:description)).to be(false)
    end
  end
end
