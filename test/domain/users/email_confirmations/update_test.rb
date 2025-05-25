# frozen_string_literal: true

require "test_helper"

class Users::EmailConfirmations::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Users::EmailConfirmations::Update }

  describe "#call" do
    describe "when rate_limiter has been exceeded" do
      it "returns failure" do
        user = create_user
        token = user.generate_token!(:email_confirmation)
        email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_email_confirmation_update:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(email_confirmation_edit, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Too many attempts/) })
        assert_equal(4, Rails.cache.read(rate_limiter_key))
      end
    end

    describe "when user is not found by token" do
      describe "non-existing token" do
        it "returns failure" do
          user = create_user
          _token = user.generate_token!(:email_confirmation)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: "xxxxxxxx")
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_email_confirmation_update:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(email_confirmation_edit, request).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end

      describe "expired token" do
        it "returns failure" do
          user = create_user
          token = user.generate_token!(:email_confirmation, 0.seconds)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_email_confirmation_update:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(email_confirmation_edit, request).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end
    end

    describe "when user is found by token" do
      describe "when email has already been confirmed" do
        it "returns failure" do
          user = create_user(email_confirmed_at: Time.current)
          token = user.generate_token!(:email_confirmation)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_email_confirmation_update:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(email_confirmation_edit, request).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Email address has already been confirmed/) })
          assert(result.user.email_confirmed_at.present?)
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end

      describe "when trying to confirm email raises an error" do
        it "raises an error and uncalls rate_limiter" do
          user = create_user
          token = user.generate_token!(:email_confirmation)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_email_confirmation_update:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          called = 0
          User.stub_any_instance(:confirm_email!, -> { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(email_confirmation_edit, request).call
            end
          end
          assert_equal(1, called)

          assert_equal(0, Rails.cache.read(rate_limiter_key))
        end
      end

      describe "when trying to confirm email succeeds" do
        it "returns success and expires tokens" do
          user = create_user
          token = user.generate_token!(:email_confirmation)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_email_confirmation_update:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(email_confirmation_edit, request).call

          assert(result.success?)
          assert(result.user.email_confirmed_at.present?)
          assert_equal(1, Rails.cache.read(rate_limiter_key))
          assert(User.find_by_token(:email_confirmation, token).blank?)
        end
      end
    end
  end
end
