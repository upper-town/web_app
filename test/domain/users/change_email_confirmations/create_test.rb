# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailConfirmations::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailConfirmations::Create }

  describe "#call" do
    describe "when rate_limiter has been exceeded" do
      it "returns failure" do
        user = create_user(password: "testpass")
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: "user.change@upper.town",
          password: "testpass"
        )
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_change_email_confirmations_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(change_email_confirmation, user.email, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Too many attempts/) })
        assert_equal(4, Rails.cache.read(rate_limiter_key))
        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when current_user_email is different than the email provided" do
      it "returns failure" do
        user = create_user(password: "testpass")
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: "user.change@upper.town",
          password: "testpass"
        )
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_change_email_confirmations_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = described_class.new(change_email_confirmation, "someone.else@upper.town", request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Incorrect current email address/) })
        assert_equal(1, Rails.cache.read(rate_limiter_key))
        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when password is incorrect" do
      it "returns failure and fails to authenticate user" do
        user = create_user(password: "testpass")
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: "user.change@upper.town",
          password: "xxxxxxxx"
        )
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_change_email_confirmations_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = described_class.new(change_email_confirmation, user.email, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Incorrect password/) })
        assert_equal(1, Rails.cache.read(rate_limiter_key))
        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when trying to update change_email raises an error" do
      it "raises an error and uncalls rate_limiter" do
        user = create_user(password: "testpass")
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: "user.change@upper.town",
          password: "testpass"
        )
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_change_email_confirmations_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        called = 0
        User.stub_any_instance(:update!, ->(*) { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
          assert_raises(ActiveRecord::ActiveRecordError) do
            described_class.new(change_email_confirmation, user.email, request).call
          end
        end
        assert_equal(1, called)

        assert_equal(0, Rails.cache.read(rate_limiter_key))
        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when trying to update change_email succeeds" do
      it "returns success and enqueues email job" do
        freeze_time do
          user = create_user(password: "testpass")
          change_email_confirmation = Users::ChangeEmailConfirmation.new(
            email: user.email,
            change_email: "user.change@upper.town",
            password: "testpass"
          )
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_change_email_confirmations_create:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(change_email_confirmation, user.email, request).call

          assert(result.success?)
          assert_equal("user.change@upper.town", result.data[:user].change_email)
          assert_nil(result.data[:user].change_email_confirmed_at)
          assert_equal(1, Rails.cache.read(rate_limiter_key))
          assert_enqueued_with(job: Users::ChangeEmailConfirmations::EmailJob, args: [user], at: 30.seconds.from_now)
        end
      end
    end
  end
end
