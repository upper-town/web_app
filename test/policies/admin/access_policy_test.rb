# frozen_string_literal: true

require "test_helper"

class Admin::AccessPolicyTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AccessPolicy }

  describe "#allowed?" do
    describe "when admin_account is nil" do
      it "returns false" do
        access_policy = described_class.new(nil, "admin_permission_key")

        assert_not(access_policy.allowed?)
      end
    end

    describe "when admin_account is super_admin" do
      it "always returns true" do
        admin_account = create_admin_account

        env_with_values("SUPER_ADMIN_ACCOUNT_IDS" => admin_account.id.to_s) do
          access_policy = described_class.new(admin_account, "admin_permission_key")

          assert(access_policy.allowed?)
        end
      end
    end

    describe "when admin_account is not a super_admin" do
      describe "when admin_account does not have the permission" do
        it "returns false" do
          admin_account = create_admin_account

          env_with_values("SUPER_ADMIN_ACCOUNT_IDS" => "") do
            access_policy = described_class.new(admin_account, "admin_permission_key")

            assert_not(access_policy.allowed?)
          end
        end
      end

      describe "when admin_account has the permission" do
        it "returns true" do
          admin_role = create_admin_role
          admin_permission = create_admin_permission(key: "admin_permission_key")
          create_admin_role_permission(admin_role:, admin_permission:)

          admin_account = create_admin_account
          create_admin_account_role(admin_account:, admin_role:)

          env_with_values("SUPER_ADMIN_ACCOUNT_IDS" => "") do
            access_policy = described_class.new(admin_account, "admin_permission_key")

            assert(access_policy.allowed?)
          end
        end
      end
    end
  end
end
