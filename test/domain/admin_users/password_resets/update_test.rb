# frozen_string_literal: true

require "test_helper"

class AdminUsers::PasswordResets::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::PasswordResets::Update }

  describe "#call" do
    describe "when admin_user is not found by token" do
      describe "non-existing token" do
        it "returns failure" do
          admin_user = create_admin_user
          token = "non-existing-token"
          code  = admin_user.generate_code!(:password_reset)

          result = described_class.new(token, code, "testpass").call

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end

      describe "expired token" do
        it "returns failure" do
          admin_user = create_admin_user
          token = admin_user.generate_token!(:password_reset, 0.seconds)
          code  = admin_user.generate_code!(:password_reset)

          result = described_class.new(token, code, "testpass").call

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end
    end

    describe "when admin_user is not found by code" do
      describe "non-existing code" do
        it "returns failure" do
          admin_user = create_admin_user
          token = admin_user.generate_token!(:password_reset)
          code  = "non-existing-code"

          result = described_class.new(token, code, "testpass").call

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end

      describe "expired code" do
        it "returns failure" do
          admin_user = create_admin_user
          token = admin_user.generate_token!(:password_reset)
          code  = admin_user.generate_code!(:password_reset, 0.seconds)

          result = described_class.new(token, code, "testpass").call

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end
    end

    describe "when admin_user is found" do
      describe "when reset password succeeds" do
        it "returns success, sets password, expires token and code" do
          admin_user = create_admin_user
          token = admin_user.generate_token!(:password_reset)
          code  = admin_user.generate_code!(:password_reset)

          result = described_class.new(token, code, "testpass").call

          assert(result.success?)
          assert_equal(admin_user, result.admin_user)
          assert(result.admin_user.password_digest.present?)
          assert(result.admin_user.password_reset_at.present?)
          assert_nil(AdminUser.find_by_token(:password_reset, token))
          assert_nil(AdminUser.find_by_code(:password_reset, code))
        end
      end

      describe "when reset password raises an error" do
        it "raises an error" do
          admin_user = create_admin_user(password: nil)
          token = admin_user.generate_token!(:password_reset)
          code  = admin_user.generate_code!(:password_reset)

          called = 0
          AdminUser.stub_any_instance(:reset_password!, ->(*) {
            called += 1
            raise ActiveRecord::ActiveRecordError
          }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(token, code, "testpass").call
            end
          end
          assert_equal(1, called)

          admin_user.reload
          assert_nil(admin_user.password_digest)
          assert_nil(admin_user.password_reset_at)
          assert_not_nil(AdminUser.find_by_token(:password_reset, token))
          assert_not_nil(AdminUser.find_by_code(:password_reset, code))
        end
      end
    end
  end
end
