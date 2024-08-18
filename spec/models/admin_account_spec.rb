# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminAccount do
  describe 'associations' do
    it 'belongs to admin_user' do
      admin_account = create(:admin_account)

      expect(admin_account.admin_user).to be_present
    end

    it 'has_may admin_account_roles' do
      admin_account = create(:admin_account)
      admin_account_role1 = create(:admin_account_role, admin_account: admin_account)
      admin_account_role2 = create(:admin_account_role, admin_account: admin_account)

      expect(admin_account.admin_account_roles)
        .to contain_exactly(admin_account_role1, admin_account_role2)
    end

    it 'has_may roles through admin_account_roles' do
      admin_account = create(:admin_account)
      admin_account_role1 = create(:admin_account_role, admin_account: admin_account)
      admin_account_role2 = create(:admin_account_role, admin_account: admin_account)

      expect(admin_account.roles)
        .to contain_exactly(admin_account_role1.admin_role, admin_account_role2.admin_role)
    end

    it 'has_may permissions through roles' do
      admin_role1 = create(:admin_role)
      admin_role2 = create(:admin_role)
      admin_permission1 = create(:admin_permission)
      admin_permission2 = create(:admin_permission)
      admin_permission3 = create(:admin_permission)
      create(:admin_role_permission, admin_role: admin_role1, admin_permission: admin_permission1)
      create(:admin_role_permission, admin_role: admin_role1, admin_permission: admin_permission2)
      create(:admin_role_permission, admin_role: admin_role2, admin_permission: admin_permission3)
      admin_account = create(:admin_account)
      create(:admin_account_role, admin_account: admin_account, admin_role: admin_role1)
      create(:admin_account_role, admin_account: admin_account, admin_role: admin_role2)

      expect(admin_account.permissions)
        .to contain_exactly(admin_permission1, admin_permission2, admin_permission3)
    end
  end

  describe '#super_admin?' do
    context 'when env var does not contain AdminAccount id' do
      it 'returns false' do
        admin_account = create(:admin_account)

        EnvVarHelper.with_values(
          'SUPER_ADMIN_ACCOUNT_IDS' => '0'
        ) do
          expect(admin_account.super_admin?).to be(false)
        end
      end
    end

    context 'when env var contains AdminAccount id' do
      it 'returns true' do
        admin_account = create(:admin_account)

        EnvVarHelper.with_values(
          'SUPER_ADMIN_ACCOUNT_IDS' => "0,#{admin_account.id}"
        ) do
          expect(admin_account.super_admin?).to be(true)
        end
      end
    end
  end
end
