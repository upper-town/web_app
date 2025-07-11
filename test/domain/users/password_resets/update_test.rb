# frozen_string_literal: true

require "test_helper"

class Users::PasswordResets::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Users::PasswordResets::Update }

  describe "#call" do
    describe "when user is not found by token" do
      describe "non-existing token" do
        it "returns failure" do
          user  = create_user
          token = "non-existing-token"
          code  = user.generate_code!(:password_reset)

          result = described_class.new(token, code, "testpass").call

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :invalid_or_expired_code))
        end
      end

      describe "expired token" do
        it "returns failure" do
          user  = create_user
          token = user.generate_token!(:password_reset, 0.seconds)
          code  = user.generate_code!(:password_reset)

          result = described_class.new(token, code, "testpass").call

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :invalid_or_expired_code))
        end
      end
    end

    describe "when user is not found by code" do
      describe "non-existing code" do
        it "returns failure" do
          user  = create_user
          token = user.generate_token!(:password_reset)
          code  = "non-existing-code"

          result = described_class.new(token, code, "testpass").call

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :invalid_or_expired_code))
        end
      end

      describe "expired code" do
        it "returns failure" do
          user  = create_user
          token = user.generate_token!(:password_reset)
          code  = user.generate_code!(:password_reset, 0.seconds)

          result = described_class.new(token, code, "testpass").call

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :invalid_or_expired_code))
        end
      end
    end

    describe "when user is found" do
      describe "when reset password succeeds" do
        it "returns success, sets password, expires token and code" do
          user  = create_user
          token = user.generate_token!(:password_reset)
          code  = user.generate_code!(:password_reset)

          result = described_class.new(token, code, "testpass").call

          assert(result.success?)
          assert(user, result.user)
          assert(result.user.password_digest.present?)
          assert(result.user.password_reset_at.present?)
          assert(User.find_by_token(:password_reset, token).blank?)
          assert(User.find_by_code(:password_reset, code).blank?)
        end
      end

      describe "when reset password raises an error" do
        it "raises an error" do
          user  = create_user
          token = user.generate_token!(:password_reset)
          code  = user.generate_code!(:password_reset)

          called = 0
          User.stub_any_instance(:reset_password!, ->(*) {
            called += 1
            raise ActiveRecord::ActiveRecordError
          }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(token, code, "testpass").call
            end
          end
          assert_equal(1, called)

          user.reload
          assert(user.password_digest.blank?)
          assert(user.password_reset_at.blank?)
        end
      end
    end
  end
end
