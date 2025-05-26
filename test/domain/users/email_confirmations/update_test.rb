# frozen_string_literal: true

require "test_helper"

class Users::EmailConfirmations::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Users::EmailConfirmations::Update }

  describe "#call" do
    describe "when user is not found by token" do
      describe "non-existing token" do
        it "returns failure" do
          user  = create_user
          token = "non-existing-token"
          code  = user.generate_code!(:email_confirmation)

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :invalid_or_expired_code))
        end
      end

      describe "expired token" do
        it "returns failure" do
          user  = create_user
          token = user.generate_token!(:email_confirmation, 0.seconds)
          code  = user.generate_code!(:email_confirmation)

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :invalid_or_expired_code))
        end
      end
    end

    describe "when user is not found by code" do
      describe "non-existing code" do
        it "returns failure" do
          user  = create_user
          token = user.generate_token!(:email_confirmation)
          code  = "non-existing-code"

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :invalid_or_expired_code))
        end
      end

      describe "expired code" do
        it "returns failure" do
          user  = create_user
          token = user.generate_token!(:email_confirmation)
          code  = user.generate_code!(:email_confirmation, 0.seconds)

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :invalid_or_expired_code))
        end
      end
    end

    describe "when user is found" do
      describe "when email has already been confirmed" do
        it "returns failure" do
          user  = create_user(email_confirmed_at: Time.current)
          token = user.generate_token!(:email_confirmation)
          code  = user.generate_code!(:email_confirmation)

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert(result.errors.of_kind?(:base, :email_address_already_confirmed))
          assert(result.user.email_confirmed_at.present?)
        end
      end

      describe "when confirm email succeeds" do
        it "returns success, expires token and code" do
          user  = create_user
          token = user.generate_token!(:email_confirmation)
          code  = user.generate_code!(:email_confirmation)

          result = described_class.new(token, code).call

          assert(result.success?)
          assert(result.user.email_confirmed_at.present?)
          assert(User.find_by_token(:email_confirmation, token).blank?)
          assert(User.find_by_code(:email_confirmation, code).blank?)
        end
      end

      describe "when confirm email raises an error" do
        it "raises an error" do
          user  = create_user
          token = user.generate_token!(:email_confirmation)
          code  = user.generate_code!(:email_confirmation)

          called = 0
          User.stub_any_instance(:confirm_email!, -> {
            called += 1
            raise ActiveRecord::ActiveRecordError
          }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(token, code).call
            end
          end
          assert_equal(1, called)

          assert(user.reload.email_confirmed_at.blank?)
        end
      end
    end
  end
end
