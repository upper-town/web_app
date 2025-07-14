# frozen_string_literal: true

require "test_helper"

class AdminUsers::EmailConfirmations::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::EmailConfirmations::Update }

  describe "#call" do
    describe "when admin_user is not found by token" do
      describe "non-existing token" do
        it "returns failure" do
          admin_user = create_admin_user
          token = "non-existing-token"
          code  = admin_user.generate_code!(:email_confirmation)

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end

      describe "expired token" do
        it "returns failure" do
          admin_user = create_admin_user
          token = admin_user.generate_token!(:email_confirmation, 0.seconds)
          code  = admin_user.generate_code!(:email_confirmation)

          result = described_class.new(token, code).call

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
          token = admin_user.generate_token!(:email_confirmation)
          code  = "non-existing-code"

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end

      describe "expired code" do
        it "returns failure" do
          admin_user = create_admin_user
          token = admin_user.generate_token!(:email_confirmation)
          code  = admin_user.generate_code!(:email_confirmation, 0.seconds)

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end
    end

    describe "when admin_user is found" do
      describe "when email has already been confirmed" do
        it "returns failure" do
          admin_user = create_admin_user(email_confirmed_at: Time.current)
          token = admin_user.generate_token!(:email_confirmation)
          code  = admin_user.generate_code!(:email_confirmation)

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_equal(admin_user, result.admin_user)
          assert(result.errors.key?(:email_address_already_confirmed))
          assert(result.admin_user.email_confirmed_at.present?)
        end
      end

      describe "when confirm email succeeds" do
        it "returns success, expires token and code" do
          admin_user = create_admin_user(email_confirmed_at: nil)
          token = admin_user.generate_token!(:email_confirmation)
          code  = admin_user.generate_code!(:email_confirmation)

          result = described_class.new(token, code).call

          assert(result.success?)
          assert_equal(admin_user, result.admin_user)
          assert(result.admin_user.email_confirmed_at.present?)
          assert_nil(AdminUser.find_by_token(:email_confirmation, token))
          assert_nil(AdminUser.find_by_code(:email_confirmation, code))
        end
      end

      describe "when confirm email raises an error" do
        it "raises an error" do
          admin_user = create_admin_user(email_confirmed_at: nil)
          token = admin_user.generate_token!(:email_confirmation)
          code  = admin_user.generate_code!(:email_confirmation)

          called = 0
          AdminUser.stub_any_instance(:confirm_email!, -> {
            called += 1
            raise ActiveRecord::ActiveRecordError
          }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(token, code).call
            end
          end
          assert_equal(1, called)

          assert_not(admin_user.reload.email_confirmed_at.present?)
          assert_not_nil(AdminUser.find_by_token(:email_confirmation, token))
          assert_not_nil(AdminUser.find_by_code(:email_confirmation, code))
        end
      end
    end
  end
end
