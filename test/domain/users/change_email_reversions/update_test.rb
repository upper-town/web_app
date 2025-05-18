# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailReversions::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailReversions::Update }

  describe "#call" do
    describe "when rate_limiter has been exceeded" do
      it "returns failure" do
        user = create_user(email: "user.change@upper.town")
        token = user.generate_token!(:change_email_reversion, 30.days, { email: "user@upper.town" })
        change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_change_email_reversions_update:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(change_email_reversion_edit, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Too many attempts/) })
        assert_equal(4, Rails.cache.read(rate_limiter_key))
      end
    end

    describe "when user is not found by token" do
      describe "non-existing token" do
        it "returns failure" do
          user = create_user(email: "user.change@upper.town")
          _token = user.generate_token!(:change_email_reversion, 30.days, { email: "user@upper.town" })
          change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: "xxxxxxxx")
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_change_email_reversions_update:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(change_email_reversion_edit, request).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end

      describe "expired token" do
        it "returns failure" do
          user = create_user(email: "user.change@upper.town")
          token = user.generate_token!(:change_email_reversion, 0.seconds, { email: "user@upper.town" })
          change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_change_email_reversions_update:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(change_email_reversion_edit, request).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end
    end

    describe "when user is found by token" do
      describe "when token data does not have the old email" do
        it "returns failure" do
          user = create_user(email: "user.change@upper.town")
          token = user.generate_token!(:change_email_reversion, 30.days, { email: " " })
          change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_change_email_reversions_update:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(change_email_reversion_edit, request).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid token: old email address is not associated with token/) })
          assert_equal(1, Rails.cache.read(rate_limiter_key))
        end
      end

      describe "when trying to revert change_email raises an error" do
        it "raises an error and uncalls rate_limiter" do
          user = create_user(email: "user.change@upper.town")
          token = user.generate_token!(:change_email_reversion, 30.days, { email: "user@upper.town" })
          change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_change_email_reversions_update:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          called = 0
          User.stub_any_instance(:revert_change_email!, ->(*) { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(change_email_reversion_edit, request).call
            end
          end
          assert_equal(1, called)

          assert_equal(0, Rails.cache.read(rate_limiter_key))
        end
      end

      describe "when trying to revert change_email succeeds" do
        it "returns success and expires tokens" do
          freeze_time do
            user = create_user(email: "user.change@upper.town")
            token = user.generate_token!(:change_email_reversion, 30.days, { email: "user@upper.town" })
            change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
            request = build_request(remote_ip: "1.1.1.1")
            rate_limiter_key = "users_change_email_reversions_update:1.1.1.1"
            Rails.cache.write(rate_limiter_key, 0)

            result = described_class.new(change_email_reversion_edit, request).call

            assert(result.success?)
            assert_equal("user@upper.town", result.data[:user].email)
            assert_equal(Time.current, result.data[:user].email_confirmed_at)
            assert_nil(result.data[:user].change_email)
            assert_nil(result.data[:user].change_email_confirmed_at)
            assert_equal(Time.current, result.data[:user].change_email_reverted_at)
            assert_equal(1, Rails.cache.read(rate_limiter_key))
            assert_nil(User.find_by_token(:change_email_reversion, token))
          end
        end
      end
    end
  end
end
