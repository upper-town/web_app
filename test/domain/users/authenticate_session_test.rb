# frozen_string_literal: true

require "test_helper"

class Users::AuthenticateSessionTest < ActiveSupport::TestCase
  let(:described_class) { Users::AuthenticateSession }

  describe "#call" do
    describe "when user is not found" do
      it "returns failure" do
        email = "user@upper.town"
        password = "testpass"

        result = described_class.call(email, password)

        assert(result.failure?)
        assert_nil(result.user)
        assert(result.errors.key?(:incorrect_password_or_email))
      end
    end

    describe "when user is found" do
      describe "when authentication succeeds" do
        it "returns success and counts sign-in attempt" do
          user = create_user(email: "user@upper.town", password: "testpass", sign_in_count: 0, failed_attempts: 0)

          result = described_class.call("user@upper.town", "testpass")

          assert(result.success?)
          assert_equal(user, result.user)
          user.reload
          assert_equal(1, user.sign_in_count)
          assert_equal(0, user.failed_attempts)
        end
      end

      describe "when authentication fails" do
        it "returns failure and counts sign-in attempt" do
          user = create_user(email: "user@upper.town", password: "testpass", sign_in_count: 0, failed_attempts: 0)

          result = described_class.call("user@upper.town", "xxxxxxxx")

          assert(result.failure?)
          assert_nil(result.user)
          assert(result.errors.key?(:incorrect_password_or_email))
          user.reload
          assert_equal(0, user.sign_in_count)
          assert_equal(1, user.failed_attempts)
        end
      end
    end
  end
end
