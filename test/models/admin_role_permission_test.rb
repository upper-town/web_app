# frozen_string_literal: true

require "test_helper"

class AdminRolePermissionTest < ActiveSupport::TestCase
  let(:described_class) { AdminRolePermission }

  describe "associations" do
    it "belongs to admin_role" do
      admin_role_permission = create_admin_role_permission

      assert(admin_role_permission.admin_role.present?)
    end

    it "belongs to admin_permission" do
      admin_role_permission = create_admin_role_permission

      assert(admin_role_permission.admin_permission.present?)
    end
  end

  describe "validations" do
    it "validates admin_permission_id scoped to admin_role_id" do
      admin_role = create_admin_role
      admin_permission = create_admin_permission
      existing_admin_role_permission = create_admin_role_permission(
        admin_role:,
        admin_permission:
      )
      admin_role_permission = build_admin_role_permission(
        admin_role:,
        admin_permission:
      )

      admin_role_permission.validate

      assert(admin_role_permission.errors.of_kind?(:admin_permission_id, :taken))

      existing_admin_role_permission.destroy!
      admin_role_permission.validate

      assert_not(admin_role_permission.errors.key?(:admin_permission_id))
    end
  end
end
