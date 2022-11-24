# frozen_string_literal: true

require 'rails_helper'
require 'support/env_var_helper'

RSpec.describe Admin::AccessPolicy do
  describe '#allowed?' do
    describe 'when admin_user is super_admin' do
      it 'always returns true' do
        admin_user = create(:admin_user, email: 'some.admin.user@example.com')

        EnvVarHelper.with_values('SUPER_ADMIN_USER_EMAILS' => 'some.admin.user@example.com') do
          access_policy = described_class.new(admin_user, 'some_admin_permission_key')

          expect(access_policy.allowed?).to be(true)
        end
      end
    end

    describe 'when admin_user is not a super_admin' do
      context 'when admin_user does not have the permission' do
        it 'returns false' do
          admin_user = create(:admin_user)

          EnvVarHelper.with_values('SUPER_ADMIN_USER_EMAILS' => '') do
            access_policy = described_class.new(admin_user, 'some_admin_permission_key')

            expect(access_policy.allowed?).to be(false)
          end
        end
      end

      context 'when admin_user has the permission' do
        it 'returns true' do
          admin_role = create(:admin_role)
          admin_permission = create(:admin_permission, key: 'some_admin_permission_key')
          create(:admin_role_permission, admin_role: admin_role, admin_permission: admin_permission)

          admin_user = create(:admin_user)
          create(:admin_user_role, admin_user: admin_user, admin_role: admin_role)

          EnvVarHelper.with_values('SUPER_ADMIN_USER_EMAILS' => '') do
            access_policy = described_class.new(admin_user, 'some_admin_permission_key')

            expect(access_policy.allowed?).to be(true)
          end
        end
      end
    end
  end
end
