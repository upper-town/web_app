# frozen_string_literal: true

require "test_helper"

class Users::AuthenticateSessionTest < ActiveSupport::TestCase
  let(:described_class) { Users::AuthenticateSession }

  describe "#call" do
    describe "when user is not found" do
      it "returns failure and does not count sign-in attempt" do
        session = Users::Session.new(email: "user@upper.town", password: "testpass")

        result = described_class.new(session).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Incorrect password or email/) })
        assert_no_enqueued_jobs(only: Users::CountSignInAttemptsJob)
      end
    end

    describe "when user is found" do
      describe "when authentication fails" do
        it "returns failure and counts sign-in attempt" do
          _user = create_user(email: "user@upper.town", password: "testpass")
          session = Users::Session.new(email: "user@upper.town", password: "xxxxxxxx")

          result = described_class.new(session).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Incorrect password or email/) })
          assert_enqueued_with(job: Users::CountSignInAttemptsJob, args: ["user@upper.town", false])
        end
      end

      describe "when authentication succeeds" do
        it "returns success and counts sign-in attempt" do
          user = create_user(email: "user@upper.town", password: "testpass")
          session = Users::Session.new(email: "user@upper.town", password: "testpass")

          result = described_class.new(session).call

          assert(result.success?)
          assert_equal(user, result.user)
          assert_enqueued_with(job: Users::CountSignInAttemptsJob, args: ["user@upper.town", true])
        end
      end
    end
  end
end
