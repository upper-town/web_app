# frozen_string_literal: true

require "test_helper"

class AdminUsers::AuthenticateSessionTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::AuthenticateSession }

  describe "#call" do
    describe "when admin_user is not found" do
      it "returns failure" do
        email = "admin_user@upper.town"
        password = "testpass"

        result = described_class.call(email, password)

        assert(result.failure?)
        assert_nil(result.admin_user)
        assert(result.errors.key?(:incorrect_password_or_email))
      end
    end

    describe "when admin_user is found" do
      describe "when authentication succeeds" do
        it "returns success and counts sign-in attempt" do
          admin_user = create_admin_user(email: "admin_user@upper.town", password: "testpass", sign_in_count: 0, failed_attempts: 0)

          result = described_class.call("admin_user@upper.town", "testpass")

          assert(result.success?)
          assert_equal(admin_user, result.admin_user)
          admin_user.reload
          assert_equal(1, admin_user.sign_in_count)
          assert_equal(0, admin_user.failed_attempts)
        end
      end

      describe "when authentication fails" do
        it "returns failure and counts sign-in attempt" do
          admin_user = create_admin_user(email: "admin_user@upper.town", password: "testpass", sign_in_count: 0, failed_attempts: 0)

          result = described_class.call("admin_user@upper.town", "xxxxxxxx")

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:incorrect_password_or_email))
          admin_user.reload
          assert_equal(0, admin_user.sign_in_count)
          assert_equal(1, admin_user.failed_attempts)
        end
      end
    end
  end
end
