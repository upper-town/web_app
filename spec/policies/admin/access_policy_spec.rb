# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AccessPolicy do
  describe '#allowed?' do
    describe 'when admin_account is nil' do
      it 'returns false' do
        access_policy = described_class.new(nil, 'admin_permission_key')

        expect(access_policy.allowed?).to be(false)
      end
    end

    describe 'when admin_account is super_admin' do
      it 'always returns true' do
        admin_account = create(:admin_account)

        EnvVarHelper.with_values('SUPER_ADMIN_ACCOUNT_IDS' => admin_account.id.to_s) do
          access_policy = described_class.new(admin_account, 'admin_permission_key')

          expect(access_policy.allowed?).to be(true)
        end
      end
    end

    describe 'when admin_account is not a super_admin' do
      context 'when admin_account does not have the permission' do
        it 'returns false' do
          admin_account = create(:admin_account)

          EnvVarHelper.with_values('SUPER_ADMIN_ACCOUNT_IDS' => '') do
            access_policy = described_class.new(admin_account, 'admin_permission_key')

            expect(access_policy.allowed?).to be(false)
          end
        end
      end

      context 'when admin_account has the permission' do
        it 'returns true' do
          admin_role = create(:admin_role)
          admin_permission = create(:admin_permission, key: 'admin_permission_key')
          create(:admin_role_permission, admin_role: admin_role, admin_permission: admin_permission)

          admin_account = create(:admin_account)
          create(:admin_account_role, admin_account: admin_account, admin_role: admin_role)

          EnvVarHelper.with_values('SUPER_ADMIN_ACCOUNT_IDS' => '') do
            access_policy = described_class.new(admin_account, 'admin_permission_key')

            expect(access_policy.allowed?).to be(true)
          end
        end
      end
    end
  end
end
