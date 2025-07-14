# frozen_string_literal: true

require "test_helper"

class AdminUsers::AuthenticateSessionTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::AuthenticateSession }

  describe "#call" do
    describe "when admin_user is not found" do
      it "returns failure and does not count sign-in attempt" do
        email    = "admin_user@upper.town"
        password = "testpass"

        result = described_class.new(email, password).call

        assert(result.failure?)
        assert_nil(result.admin_user)
        assert(result.errors.key?(:incorrect_password_or_email))
        assert_no_enqueued_jobs(only: AdminUsers::CountSignInAttemptsJob)
      end
    end

    describe "when admin_user is found" do
      describe "when authentication succeeds" do
        it "returns success and counts sign-in attempt" do
          admin_user = create_admin_user(email: "admin_user@upper.town", password: "testpass")

          result = described_class.new("admin_user@upper.town", "testpass").call

          assert(result.success?)
          assert_equal(admin_user, result.admin_user)
          assert_enqueued_with(job: AdminUsers::CountSignInAttemptsJob, args: ["admin_user@upper.town", true])
        end
      end

      describe "when authentication fails" do
        it "returns failure and counts sign-in attempt" do
          create_admin_user(email: "admin_user@upper.town", password: "testpass")

          result = described_class.new("admin_user@upper.town", "xxxxxxxx").call

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:incorrect_password_or_email))
          assert_enqueued_with(job: AdminUsers::CountSignInAttemptsJob, args: ["admin_user@upper.town", false])
        end
      end
    end
  end
end
