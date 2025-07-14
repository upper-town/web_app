# frozen_string_literal: true

require "test_helper"

class AdminAccountRoleTest < ActiveSupport::TestCase
  let(:described_class) { AdminAccountRole }

  describe "associations" do
    it "belongs to admin_account" do
      admin_account_role = create_admin_account_role

      assert(admin_account_role.admin_account.present?)
    end

    it "belongs to admin_role" do
      admin_account_role = create_admin_account_role

      assert(admin_account_role.admin_role.present?)
    end
  end

  describe "validations" do
    it "validates admin_role_id scoped to admin_account_id" do
      admin_account = create_admin_account
      admin_role = create_admin_role
      existing_admin_account_role = create_admin_account_role(
        admin_account:,
        admin_role:
      )
      admin_account_role = build_admin_account_role(
        admin_account:,
        admin_role:
      )

      admin_account_role.validate

      assert(admin_account_role.errors.of_kind?(:admin_role_id, :taken))

      existing_admin_account_role.destroy!
      admin_account_role.validate

      assert_not(admin_account_role.errors.key?(:admin_role_id))
    end
  end
end
