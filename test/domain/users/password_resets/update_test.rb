# frozen_string_literal: true

require "test_helper"

class Users::PasswordResets::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Users::PasswordResets::Update }

  describe "#call" do
    describe "when user is not found by token" do
      describe "non-existing token" do
        it "returns failure" do
          user = create_user
          _token = user.generate_token!(:password_reset)
          password_reset_edit = Users::PasswordResetEdit.new(token: "xxxxxxxx")

          result = described_class.new(password_reset_edit).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
        end
      end

      describe "expired token" do
        it "returns failure" do
          user = create_user
          token = user.generate_token!(:password_reset, 0.seconds)
          password_reset_edit = Users::PasswordResetEdit.new(token: token)

          result = described_class.new(password_reset_edit).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
        end
      end
    end

    describe "when user is found by token" do
      describe "when trying to reset password raises an error" do
        it "raises an error" do
          user = create_user
          token = user.generate_token!(:password_reset)
          password_reset_edit = Users::PasswordResetEdit.new(token: token)

          called = 0
          User.stub_any_instance(:reset_password!, ->(*) { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(password_reset_edit).call
            end
          end
          assert_equal(1, called)
        end
      end

      describe "when trying to reset password succeeds" do
        it "returns success and expires tokens" do
          user = create_user
          token = user.generate_token!(:password_reset)
          password_reset_edit = Users::PasswordResetEdit.new(token: token)

          result = described_class.new(password_reset_edit).call

          assert(result.success?)
          assert(result.user.password_reset_at.present?)
          assert(User.find_by_token(:password_reset, token).blank?)
        end
      end
    end
  end
end
