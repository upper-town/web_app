# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailReversions::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailReversions::Update }

  describe "#call" do
    describe "when user is not found by token" do
      describe "someone else's token" do
        it "returns failure" do
          user = create_user(email: "user.new@upper.town")

          token = create_user.generate_token!(:change_email_reversion)
          code  = user.generate_code!(:change_email_reversion, nil, { email: "user@upper.town" })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end

      describe "expired token" do
        it "returns failure" do
          user = create_user(email: "user.new@upper.town")

          token = user.generate_token!(:change_email_reversion, 0.seconds)
          code  = user.generate_code!(:change_email_reversion, nil, { email: "user@upper.town" })

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
          user = create_user(email: "user.new@upper.town")

          token = user.generate_token!(:change_email_reversion)
          code  = create_user.generate_code!(:change_email_reversion, nil, { email: "user@upper.town" })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end

      describe "expired code" do
        it "returns failure" do
          user = create_user(email: "user.new@upper.town")

          token = user.generate_token!(:change_email_reversion)
          code  = user.generate_code!(:change_email_reversion, 0.seconds, { email: "user@upper.town" })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_nil(result.user)
          assert(result.errors.key?(:invalid_or_expired_token_or_code))
        end
      end
    end

    describe "when user is found" do
      describe "when code data does not have the old email" do
        it "returns failure" do
          user = create_user(email: "user.new@upper.town")

          token = user.generate_token!(:change_email_reversion)
          code  = user.generate_code!(:change_email_reversion, nil, { email: "" })

          result = described_class.new(token, code).call

          assert(result.failure?)
          assert_equal(user, result.user)
          assert(result.errors.key?(:old_email_not_associated_with_code))
        end
      end

      describe "when trying to revert change_email raises an error" do
        it "raises an error" do
          user = create_user(email: "user.new@upper.town")

          token = user.generate_token!(:change_email_reversion, nil)
          code  = user.generate_code!(:change_email_reversion, nil, { email: "user@upper.town" })

          called = 0
          User.stub_any_instance(:revert_change_email!, ->(*) { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(token, code).call
            end
          end
          assert_equal(1, called)

          user.reload
          assert_equal("user.new@upper.town", user.email)
          assert_not_nil(User.find_by_token(:change_email_reversion, token))
          assert_not_nil(User.find_by_code(:change_email_reversion, code))
        end
      end

      describe "when trying to revert change_email succeeds" do
        it "returns success and expires token" do
          freeze_time do
            user = create_user(email: "user.new@upper.town")

            token = user.generate_token!(:change_email_reversion)
            code  = user.generate_code!(:change_email_reversion, nil, { email: "user@upper.town" })

            result = described_class.new(token, code).call

            user.reload
            assert(result.success?)
            assert_equal(user, result.user)
            assert_equal("user@upper.town", user.email)
            assert_equal(Time.current, user.email_confirmed_at)
            assert_nil(user.change_email)
            assert_nil(user.change_email_confirmed_at)
            assert_equal(Time.current, user.change_email_reverted_at)
            assert_nil(User.find_by_token(:change_email_reversion, token))
            assert_nil(User.find_by_code(:change_email_reversion, code))
          end
        end
      end
    end
  end
end
