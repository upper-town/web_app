# frozen_string_literal: true

require "test_helper"

class Users::PasswordResets::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Users::PasswordResets::Create }

  describe "#call" do
    describe "when rate_limiter has been exceeded" do
      it "returns failure" do
        _user = create_user(email: "user@upper.town")
        password_reset = Users::PasswordReset.new(email: "user@upper.town")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_password_resets_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(password_reset, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Too many requests/) })
        assert_equal(4, Rails.cache.read(rate_limiter_key))
        assert_no_enqueued_jobs(only: Users::PasswordResets::EmailJob)
      end
    end

    describe "when user is not found" do
      it "returns success but doesn not enqueue job to send email" do
        _user = create_user(email: "user@upper.town")
        password_reset = Users::PasswordReset.new(email: "xxxxxxxx@upper.town")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_password_resets_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = described_class.new(password_reset, request).call

        assert(result.success?)
        assert_equal(1, Rails.cache.read(rate_limiter_key))
        assert_no_enqueued_jobs(only: Users::PasswordResets::EmailJob)
      end
    end

    describe "when user is found" do
      it "returns success and enqueues job to send email" do
        user = create_user(email: "user@upper.town")
        password_reset = Users::PasswordReset.new(email: "user@upper.town")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_password_resets_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = described_class.new(password_reset, request).call

        assert(result.success?)
        assert_equal(1, Rails.cache.read(rate_limiter_key))
        assert_enqueued_with(job: Users::PasswordResets::EmailJob, args: [user])
      end
    end
  end
end
