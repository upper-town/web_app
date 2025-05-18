# frozen_string_literal: true

require "test_helper"

class AdminRoleTest < ActiveSupport::TestCase
  let(:described_class) { AdminRole }

  describe "associations" do
    it "has many admin_account_roles" do
      admin_role = create_admin_role
      admin_account_role1 = create_admin_account_role(admin_role: admin_role)
      admin_account_role2 = create_admin_account_role(admin_role: admin_role)

      assert_equal(
        [admin_account_role1, admin_account_role2].sort,
        admin_role.admin_account_roles.sort
      )
      admin_role.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { admin_account_role1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { admin_account_role2.reload }
    end

    it "has many admin_role_permissions" do
      admin_role = create_admin_role
      admin_role_permission1 = create_admin_role_permission(admin_role: admin_role)
      admin_role_permission2 = create_admin_role_permission(admin_role: admin_role)

      assert_equal(
        [admin_role_permission1, admin_role_permission2].sort,
        admin_role.admin_role_permissions.sort
      )
      admin_role.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { admin_role_permission1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { admin_role_permission2.reload }
    end

    it "has many accounts through admin_account_roles" do
      admin_role = create_admin_role
      admin_account_role1 = create_admin_account_role(admin_role: admin_role)
      admin_account_role2 = create_admin_account_role(admin_role: admin_role)

      assert_equal(
        [admin_account_role1.admin_account, admin_account_role2.admin_account].sort,
        admin_role.accounts.sort
      )
    end

    it "has many permissions through admin_role_permissions" do
      admin_role = create_admin_role
      admin_role_permission1 = create_admin_role_permission(admin_role: admin_role)
      admin_role_permission2 = create_admin_role_permission(admin_role: admin_role)

      assert_equal(
        [admin_role_permission1.admin_permission, admin_role_permission2.admin_permission].sort,
        admin_role.permissions.sort
      )
    end
  end

  describe "normalizations" do
    it "normalizes key" do
      admin_role = create_admin_role(key: "\n\t Admin  Role Key\n")

      assert_equal("admin_role_key", admin_role.key)
    end

    it "normalizes description" do
      admin_role = create_admin_role(description: "\n\t AdminRole  description \n")

      assert_equal("AdminRole description", admin_role.description)
    end
  end

  describe "validations" do
    it "validates key" do
      admin_role = build_admin_role(key: " ")
      admin_role.validate
      assert(admin_role.errors.of_kind?(:key, :blank))

      another_admin_role = create_admin_role(key: "Admin_Role_Key")

      admin_role = build_admin_role(key: "admin_role_key")
      admin_role.validate
      assert(admin_role.errors.of_kind?(:key, :taken))

      another_admin_role.destroy!

      admin_role = build_admin_role(key: "admin_role_key")
      admin_role.validate
      assert_not(admin_role.errors.key?(:key))
    end

    it "validates description" do
      admin_role = build_admin_role(description: " ")
      admin_role.validate
      assert(admin_role.errors.of_kind?(:description, :blank))

      admin_role = build_admin_role(description: "AdminRole description")
      admin_role.validate
      assert_not(admin_role.errors.key?(:description))
    end
  end
end
