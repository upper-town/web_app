# frozen_string_literal: true

require "test_helper"

class Users::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Users::Create }

  describe "#call" do
    describe "when user does not exist" do
      it "creates user, sends email confirmation, and returns success" do
        email = "user@upper.town"

        result = nil
        assert_difference(-> { User.count }, 1) do
          assert_difference(-> { Account.count }, 1) do
            result = described_class.new(email).call
          end
        end

        assert(result.success?)

        last_user = User.last
        assert_equal(last_user, result.user)
        assert_equal(last_user.account, result.user.account)
        assert_equal(email, last_user.email)
        assert(last_user.email_confirmed_at.blank?)

        assert_enqueued_with(
          job: Users::EmailConfirmations::EmailJob,
          args: [result.user]
        )
      end

      describe "when user is invalid" do
        it "returns failure with user errors" do
          email = "invalid-email"

          result = nil
          assert_no_difference(-> { User.count }) do
            assert_no_difference(-> { Account.count }) do
              result = described_class.new(email).call
            end
          end

          assert(result.failure?)
          assert_nil(result.user)
          assert(result.errors.key?(:email))

          assert_no_enqueued_jobs(only: Users::EmailConfirmations::EmailJob)
        end
      end

      describe "when error is raised trying to create user" do
        it "raises error" do
          email = "user@upper.town"

          called = 0
          User.stub_any_instance(:save!, -> {
            called += 1
            raise ActiveRecord::ActiveRecordError
          }) do
            assert_no_difference(-> { User.count }) do
              assert_no_difference(-> { Account.count }) do
                assert_raises(ActiveRecord::ActiveRecordError) do
                  described_class.new(email).call
                end
              end
            end
          end
          assert_equal(1, called)

          assert_no_enqueued_jobs(only: Users::EmailConfirmations::EmailJob)
        end
      end

      describe "when error is raised trying to create account" do
        it "raises error" do
          email = "user@upper.town"

          called = 0
          User.stub_any_instance(:create_account!, -> {
            called += 1
            raise ActiveRecord::ActiveRecordError
          }) do
            assert_no_difference(-> { User.count }) do
              assert_no_difference(-> { Account.count }) do
                assert_raises(ActiveRecord::ActiveRecordError) do
                  described_class.new(email).call
                end
              end
            end
          end
          assert_equal(1, called)

          assert_no_enqueued_jobs(only: Users::EmailConfirmations::EmailJob)
        end
      end
    end

    describe "when user already exists" do
      it "finds user, sends email confirmation, and returns success" do
        email = "user@upper.town"
        existing_user = create_user(email:, account: create_account)

        result = nil
        assert_no_difference(-> { User.count }) do
          assert_no_difference(-> { Account.count }) do
            result = described_class.new(email).call
          end
        end

        assert(result.success?)

        assert_equal(existing_user, result.user)
        assert_equal(existing_user.account, result.user.account)
        assert_equal(email, existing_user.email)

        assert_enqueued_with(
          job: Users::EmailConfirmations::EmailJob,
          args: [result.user]
        )
      end
    end
  end
end
