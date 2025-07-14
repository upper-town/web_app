# frozen_string_literal: true

require "test_helper"

class AdminUsers::CreateTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::Create }

  describe "#call" do
    describe "when admin_user does not exist" do
      it "creates admin_user, sends email confirmation, and returns success" do
        email = "admin_user@upper.town"

        result = nil
        assert_difference(-> { AdminUser.count }, 1) do
          assert_difference(-> { AdminAccount.count }, 1) do
            result = described_class.new(email).call
          end
        end

        assert(result.success?)

        last_admin_user = AdminUser.last
        assert_equal(last_admin_user, result.admin_user)
        assert_equal(last_admin_user.account, result.admin_user.account)
        assert_equal(email, last_admin_user.email)
        assert(last_admin_user.email_confirmed_at.blank?)

        assert_enqueued_with(
          job: AdminUsers::EmailConfirmations::EmailJob,
          args: [result.admin_user]
        )
      end

      describe "when admin_user is invalid" do
        it "returns failure with admin_user errors" do
          email = "invalid-email"

          result = nil
          assert_no_difference(-> { AdminUser.count }) do
            assert_no_difference(-> { AdminAccount.count }) do
              result = described_class.new(email).call
            end
          end

          assert(result.failure?)
          assert_nil(result.admin_user)
          assert(result.errors.key?(:email))

          assert_no_enqueued_jobs(only: AdminUsers::EmailConfirmations::EmailJob)
        end
      end

      describe "when error is raised trying to create admin_user" do
        it "raises error" do
          email = "admin_user@upper.town"

          called = 0
          AdminUser.stub_any_instance(:save!, -> {
            called += 1
            raise ActiveRecord::ActiveRecordError
          }) do
            assert_no_difference(-> { AdminUser.count }) do
              assert_no_difference(-> { AdminAccount.count }) do
                assert_raises(ActiveRecord::ActiveRecordError) do
                  described_class.new(email).call
                end
              end
            end
          end
          assert_equal(1, called)

          assert_no_enqueued_jobs(only: AdminUsers::EmailConfirmations::EmailJob)
        end
      end

      describe "when error is raised trying to create account" do
        it "raises error" do
          email = "admin_user@upper.town"

          called = 0
          AdminUser.stub_any_instance(:create_account!, -> {
            called += 1
            raise ActiveRecord::ActiveRecordError
          }) do
            assert_no_difference(-> { AdminUser.count }) do
              assert_no_difference(-> { AdminAccount.count }) do
                assert_raises(ActiveRecord::ActiveRecordError) do
                  described_class.new(email).call
                end
              end
            end
          end
          assert_equal(1, called)

          assert_no_enqueued_jobs(only: AdminUsers::EmailConfirmations::EmailJob)
        end
      end
    end

    describe "when admin_user already exists" do
      it "finds admin_user, sends email confirmation, and returns success" do
        email = "admin_user@upper.town"
        existing_admin_user = create_admin_user(email:, account: create_admin_account)

        result = nil
        assert_no_difference(-> { AdminUser.count }) do
          assert_no_difference(-> { AdminAccount.count }) do
            result = described_class.new(email).call
          end
        end

        assert(result.success?)

        assert_equal(existing_admin_user, result.admin_user)
        assert_equal(existing_admin_user.account, result.admin_user.account)
        assert_equal(email, existing_admin_user.email)

        assert_enqueued_with(
          job: AdminUsers::EmailConfirmations::EmailJob,
          args: [result.admin_user]
        )
      end
    end
  end
end
