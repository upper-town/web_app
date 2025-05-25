# frozen_string_literal: true

require "test_helper"

class AdminUsers::EmailConfirmations::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::EmailConfirmations::Update }

  describe "#call" do
    describe "when admin_user is not found by token" do
      describe "non-existing token" do
        it "returns failure" do
          admin_user = create_admin_user
          _token = admin_user.generate_token!(:email_confirmation)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: "xxxxxxxx")

          result = described_class.new(email_confirmation_edit).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
        end
      end

      describe "expired token" do
        it "returns failure" do
          admin_user = create_admin_user
          token = admin_user.generate_token!(:email_confirmation, 0.seconds)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: token)

          result = described_class.new(email_confirmation_edit).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
        end
      end
    end

    describe "when admin_user is found by token" do
      describe "when email has already been confirmed" do
        it "returns failure" do
          admin_user = create_admin_user(email_confirmed_at: Time.current)
          token = admin_user.generate_token!(:email_confirmation)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: token)

          result = described_class.new(email_confirmation_edit).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Email address has already been confirmed/) })
          assert(result.admin_user.email_confirmed_at.present?)
        end
      end

      describe "when trying to confirm email raises an error" do
        it "raises an error" do
          admin_user = create_admin_user
          token = admin_user.generate_token!(:email_confirmation)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: token)

          called = 0
          AdminUser.stub_any_instance(:confirm_email!, -> { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(email_confirmation_edit).call
            end
          end
          assert_equal(1, called)
        end
      end

      describe "when trying to confirm email succeeds" do
        it "returns success and expires tokens" do
          admin_user = create_admin_user
          token = admin_user.generate_token!(:email_confirmation)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: token)

          result = described_class.new(email_confirmation_edit).call

          assert(result.success?)
          assert(result.admin_user.email_confirmed_at.present?)
          assert(AdminUser.find_by_token(:email_confirmation, token).blank?)
        end
      end
    end
  end
end
