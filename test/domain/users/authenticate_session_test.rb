# frozen_string_literal: true

require "test_helper"

class Users::AuthenticateSessionTest < ActiveSupport::TestCase
  let(:described_class) { Users::AuthenticateSession }

  describe "#call" do
    describe "when rate_limiter has been exceeded" do
      it "returns failure and does not count sign-in attempt" do
        _user = create_user(email: "user@upper.town", password: "testpass")
        session = Users::Session.new(email: "user@upper.town", password: "testpass")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_authenticate_session:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(session, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Too many attempts/) })
        assert_no_enqueued_jobs(only: Users::CountSignInAttemptsJob)
        assert_equal(4, Rails.cache.read(rate_limiter_key))
      end
    end

    describe "when user is not found" do
      it "returns failure and does not count sign-in attempt" do
        session = Users::Session.new(email: "user@upper.town", password: "testpass")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_authenticate_session:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = described_class.new(session, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Incorrect password or email/) })
        assert_no_enqueued_jobs(only: Users::CountSignInAttemptsJob)
        assert_equal(1, Rails.cache.read(rate_limiter_key))
      end
    end

    describe "when user is found" do
      describe "when authentication fails" do
        it "returns failure and counts sign-in attempt" do
          _user = create_user(email: "user@upper.town", password: "testpass")
          session = Users::Session.new(email: "user@upper.town", password: "xxxxxxxx")
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_authenticate_session:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(session, request).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Incorrect password or email/) })
          assert_enqueued_with(job: Users::CountSignInAttemptsJob, args: ["user@upper.town", false])
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end

      describe "when authentication succeeds" do
        it "returns success and counts sign-in attempt" do
          user = create_user(email: "user@upper.town", password: "testpass")
          session = Users::Session.new(email: "user@upper.town", password: "testpass")
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_authenticate_session:1.1.1.1"
          Rails.cache.write(rate_limiter_key, "0")

          result = described_class.new(session, request).call

          assert(result.success?)
          assert_equal(user, result.user)
          assert_enqueued_with(job: Users::CountSignInAttemptsJob, args: ["user@upper.town", true])
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end
    end
  end
end
