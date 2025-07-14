# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailConfirmations::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailConfirmations::Update }

  describe "#call" do
    describe "when user is not found by token" do
      describe "someone else's token" do
        it "returns failure" do
          user = create_user(
            email: "user@upper.town",
            change_email: "user.new@upper.town",
            change_email_confirmed_at: nil
          )

          token = create_user.generate_token!(:change_email_confirmation)
          code  = user.generate_code!(:change_email_confirmation, nil, { "change_email" => user.change_email })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end

      describe "expired token" do
        it "returns failure" do
          user = create_user(
            email: "user@upper.town",
            change_email: "user.new@upper.town",
            change_email_confirmed_at: nil
          )

          token = user.generate_token!(:change_email_confirmation, 0.seconds)
          code  = user.generate_code!(:change_email_confirmation, nil, { "change_email" => user.change_email })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end
    end

    describe "when user is not found by code" do
      describe "someone else's code" do
        it "returns failure" do
          user = create_user(
            email: "user@upper.town",
            change_email: "user.new@upper.town",
            change_email_confirmed_at: nil
          )

          token = user.generate_token!(:change_email_confirmation)
          code  = create_user.generate_code!(:change_email_confirmation, nil, { "change_email" => user.change_email })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end

      describe "expired code" do
        it "returns failure" do
          user = create_user(
            email: "user@upper.town",
            change_email: "user.new@upper.town",
            change_email_confirmed_at: nil
          )

          token = user.generate_token!(:change_email_confirmation)
          code  = user.generate_code!(:change_email_confirmation, 0.seconds, { "change_email" => user.change_email })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end
    end

    describe "when user is found" do
      describe "when new email has already been confirmed" do
        it "returns failure" do
          user = create_user(
            email: "user@upper.town",
            change_email: "user.new@upper.town",
            change_email_confirmed_at: Time.current
          )

          token = user.generate_token!(:change_email_confirmation)
          code  = user.generate_code!(:change_email_confirmation, nil, { "change_email" => user.change_email })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_equal(user, result.user)
          assert(result.errors.key?(:new_email_address_already_confirmed))
          assert(result.user.change_email_confirmed_at.present?)
        end
      end

      describe "when code.data change_email doesn't match user.change_email" do
        it "returns failure" do
          user = create_user(
            email: "user@upper.town",
            change_email: "user.new@upper.town",
            change_email_confirmed_at: nil
          )

          token = user.generate_token!(:change_email_confirmation)
          code  = user.generate_code!(:change_email_confirmation, nil, { "change_email" => "someone.else@upper.town" })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_equal(user, result.user)
          assert(result.errors.key?(:new_email_not_associated_with_code))
          assert(result.user.change_email_confirmed_at.blank?)
        end
      end

      describe "when confirm change email succeeds" do
        it "returns success, expires token and code" do
          freeze_time do
            user = create_user(
              email: "user@upper.town",
              change_email: "user.new@upper.town",
              change_email_confirmed_at: nil
            )

            token = user.generate_token!(:change_email_confirmation)
            code  = user.generate_code!(:change_email_confirmation, nil, { "change_email" => user.change_email })

            result = described_class.new(token, code).call

            assert(result.success?)
            assert_equal(user, result.user)
            assert_equal(Time.current, result.user.change_email_confirmed_at)
            assert_equal(Time.current, result.user.email_confirmed_at)
            assert_nil(User.find_by_token(:change_email_confirmation, token))
            assert_nil(User.find_by_code(:change_email_confirmation, code))
          end
        end
      end

      describe "when confirm email raises an error" do
        it "raises an error" do
          user = create_user(
            email: "user@upper.town",
            change_email: "user.new@upper.town",
            change_email_confirmed_at: nil
          )

          token = user.generate_token!(:change_email_confirmation)
          code  = user.generate_code!(:change_email_confirmation, nil, { "change_email" => user.change_email })

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

          assert_not(user.reload.change_email_confirmed_at.present?)
          assert_not_nil(User.find_by_token(:change_email_confirmation, token))
          assert_not_nil(User.find_by_code(:change_email_confirmation, code))
        end
      end
    end
  end
end
