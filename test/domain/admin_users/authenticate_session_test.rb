# frozen_string_literal: true

require "test_helper"

class AdminUsers::AuthenticateSessionTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::AuthenticateSession }

  describe "#call" do
    describe "when rate_limiter has been exceeded" do
      it "returns failure and does not count sign-in attempt" do
        _admin_user = create_admin_user(email: "admin.user@upper.town", password: "testpass")
        session = AdminUsers::Session.new(email: "admin.user@upper.town", password: "testpass")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "admin_users_authenticate_session:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(session, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Too many attempts/) })
        assert_no_enqueued_jobs(only: AdminUsers::CountSignInAttemptsJob)
        assert_equal(4, Rails.cache.read(rate_limiter_key))
      end
    end

    describe "when admin_user is not found" do
      it "returns failure and does not count sign-in attempt" do
        session = AdminUsers::Session.new(email: "admin.user@upper.town", password: "testpass")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "admin_users_authenticate_session:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = described_class.new(session, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Incorrect password or email/) })
        assert_no_enqueued_jobs(only: AdminUsers::CountSignInAttemptsJob)
        assert_equal(1, Rails.cache.read(rate_limiter_key))
      end
    end

    describe "when admin_user is found" do
      describe "when authentication fails" do
        it "returns failure and counts sign-in attempt" do
          _admin_user = create_admin_user(email: "admin.user@upper.town", password: "testpass")
          session = AdminUsers::Session.new(email: "admin.user@upper.town", password: "xxxxxxxx")
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "admin_users_authenticate_session:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(session, request).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Incorrect password or email/) })
          assert_enqueued_with(job: AdminUsers::CountSignInAttemptsJob, args: ["admin.user@upper.town", false])
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end

      describe "when authentication succeeds" do
        it "returns success and counts sign-in attempt" do
          admin_user = create_admin_user(email: "admin.user@upper.town", password: "testpass")
          session = AdminUsers::Session.new(email: "admin.user@upper.town", password: "testpass")
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "admin_users_authenticate_session:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(session, request).call

          assert(result.success?)
          assert_equal(admin_user, result.data[:admin_user])
          assert_enqueued_with(job: AdminUsers::CountSignInAttemptsJob, args: ["admin.user@upper.town", true])
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end
    end
  end
end
