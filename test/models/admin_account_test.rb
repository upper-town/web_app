# frozen_string_literal: true

require "test_helper"

class AdminAccountTest < ActiveSupport::TestCase
  let(:described_class) { AdminAccount }

  describe "associations" do
    it "belongs to admin_user" do
      admin_account = create_admin_account

      assert(admin_account.admin_user.present?)
    end

    it "has_may admin_account_roles" do
      admin_account = create_admin_account
      admin_account_role1 = create_admin_account_role(admin_account:)
      admin_account_role2 = create_admin_account_role(admin_account:)

      assert_equal(
        [admin_account_role1, admin_account_role2].sort,
        admin_account.admin_account_roles.sort
      )
    end

    it "has_may roles through admin_account_roles" do
      admin_account = create_admin_account
      admin_account_role1 = create_admin_account_role(admin_account:)
      admin_account_role2 = create_admin_account_role(admin_account:)

      assert_equal(
        [admin_account_role1.admin_role, admin_account_role2.admin_role].sort,
        admin_account.roles.sort
      )
    end

    it "has_may distinct permissions through roles" do
      admin_role1 = create_admin_role
      admin_role2 = create_admin_role
      admin_permission1 = create_admin_permission
      admin_permission2 = create_admin_permission
      admin_permission3 = create_admin_permission
      create_admin_role_permission(admin_role: admin_role1, admin_permission: admin_permission1)
      create_admin_role_permission(admin_role: admin_role1, admin_permission: admin_permission2)
      create_admin_role_permission(admin_role: admin_role2, admin_permission: admin_permission1)
      create_admin_role_permission(admin_role: admin_role2, admin_permission: admin_permission3)
      admin_account = create_admin_account
      create_admin_account_role(admin_account:, admin_role: admin_role1)
      create_admin_account_role(admin_account:, admin_role: admin_role2)

      assert_equal(
        [admin_permission1, admin_permission2, admin_permission3].sort,
        admin_account.permissions.sort
      )
    end
  end

  describe "#super_admin?" do
    describe "when env var does not contain AdminAccount id" do
      it "returns false" do
        admin_account = create_admin_account

        env_with_values("SUPER_ADMIN_ACCOUNT_IDS" => "0") do
          assert_not(admin_account.super_admin?)
        end
      end
    end

    describe "when env var contains AdminAccount id" do
      it "returns true" do
        admin_account = create_admin_account

        env_with_values("SUPER_ADMIN_ACCOUNT_IDS" => "0,#{admin_account.id}") do
          assert(admin_account.super_admin?)
        end
      end
    end
  end
end
