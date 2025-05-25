# frozen_string_literal: true

require "test_helper"

class Users::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Users::Create }

  describe "#call" do
    describe "when user does not exist" do
      it "returns success, creates user and sends email confirmation" do
        email_confirmation = Users::EmailConfirmation.new(email: "user@upper.town")

        result = nil
        assert_difference(-> { User.count }, 1) do
          assert_difference(-> { Account.count }, 1) do
            result = described_class.new(email_confirmation).call
          end
        end

        user = User.last
        account = Account.last
        assert_equal("user@upper.town", user.email)
        assert(user.account.present?)
        assert_equal(account, user.account)
        assert(user.email_confirmed_at.blank?)

        assert(result.success?)
        assert_enqueued_with(job: Users::EmailConfirmations::EmailJob, args: [user])
      end

      describe "when an error is raised trying to create user" do
        it "raises error" do
          email_confirmation = Users::EmailConfirmation.new(email: "user@upper.town")

          called = 0
          User.stub_any_instance(:save!, -> { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(email_confirmation).call
            end
          end
          assert_equal(1, called)

          assert_no_enqueued_jobs(only: Users::EmailConfirmations::EmailJob)
        end
      end
    end

    describe "when user already exists" do
      it "returns success, finds user and sends email confirmation" do
        user = create_user(email: "user@upper.town")
        email_confirmation = Users::EmailConfirmation.new(email: "user@upper.town")

        result = nil
        assert_no_difference(-> { User.count }) do
          assert_no_difference(-> { Account.count }) do
            result = described_class.new(email_confirmation).call
          end
        end

        assert(result.success?)
        assert_enqueued_with(job: Users::EmailConfirmations::EmailJob, args: [user])
      end
    end
  end
end
