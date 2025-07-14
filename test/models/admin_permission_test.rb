# frozen_string_literal: true

require "test_helper"

class AdminPermissionTest < ActiveSupport::TestCase
  let(:described_class) { AdminPermission }

  describe "associations" do
    it "has many admin_role_permissions" do
      admin_permission = create_admin_permission
      admin_role_permission1 = create_admin_role_permission(admin_permission:)
      admin_role_permission2 = create_admin_role_permission(admin_permission:)

      assert_equal(
        [admin_role_permission1, admin_role_permission2].sort,
        admin_permission.admin_role_permissions.sort
      )
      admin_permission.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { admin_role_permission1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { admin_role_permission2.reload }
    end

    it "has many roles through admin_role_permissions" do
      admin_permission = create_admin_permission
      admin_role_permission1 = create_admin_role_permission(admin_permission:)
      admin_role_permission2 = create_admin_role_permission(admin_permission:)

      assert_equal(
        [admin_role_permission1.admin_role, admin_role_permission2.admin_role].sort,
        admin_permission.roles.sort
      )
    end

    it "has many distinct accounts through roles" do
      admin_account1 = create_admin_account
      admin_account2 = create_admin_account
      admin_role1 = create_admin_role
      admin_role2 = create_admin_role
      admin_role3 = create_admin_role
      create_admin_account_role(admin_account: admin_account1, admin_role: admin_role1)
      create_admin_account_role(admin_account: admin_account1, admin_role: admin_role2)
      create_admin_account_role(admin_account: admin_account2, admin_role: admin_role3)
      admin_permission = create_admin_permission
      create_admin_role_permission(admin_role: admin_role1, admin_permission:)
      create_admin_role_permission(admin_role: admin_role2, admin_permission:)
      create_admin_role_permission(admin_role: admin_role3, admin_permission:)

      assert_equal(
        [admin_account1, admin_account2].sort,
        admin_permission.accounts.sort
      )
    end
  end

  describe "normalizations" do
    it "normalizes key" do
      admin_permission = create_admin_permission(key: "\n\t Admin  Permission Key \n")

      assert_equal("admin_permission_key", admin_permission.key)
    end

    it "normalizes description" do
      admin_permission = create_admin_permission(description: "\n\t AdminPermission  description \n")

      assert_equal("AdminPermission description", admin_permission.description)
    end
  end

  describe "validations" do
    it "validates key" do
      admin_permission = build_admin_permission(key: " ")
      admin_permission.validate
      assert(admin_permission.errors.of_kind?(:key, :blank))

      another_admin_permission = create_admin_permission(key: "Admin_Permission_Key")

      admin_permission = build_admin_permission(key: "admin_permission_key")
      admin_permission.validate
      assert(admin_permission.errors.of_kind?(:key, :taken))

      another_admin_permission.destroy!

      admin_permission = build_admin_permission(key: "admin_permission_key")
      admin_permission.validate
      assert_not(admin_permission.errors.key?(:key))
    end

    it "validates description" do
      admin_permission = build_admin_permission(description: " ")
      admin_permission.validate
      assert(admin_permission.errors.of_kind?(:description, :blank))

      admin_permission = build_admin_permission(description: "AdminPermission description")
      admin_permission.validate
      assert_not(admin_permission.errors.key?(:description))
    end
  end
end
