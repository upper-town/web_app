# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailConfirmations::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailConfirmations::Create }

  describe "#call" do
    describe "when current_user_email is different than the email provided" do
      it "returns failure" do
        user = create_user(password: "testpass")
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: "user.change@upper.town",
          password: "testpass"
        )

        result = described_class.new(change_email_confirmation, "someone.else@upper.town").call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Incorrect current email address/) })
        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when password is incorrect" do
      it "returns failure and fails to authenticate user" do
        user = create_user(password: "testpass")
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: "user.change@upper.town",
          password: "xxxxxxxx"
        )

        result = described_class.new(change_email_confirmation, user.email).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Incorrect password/) })
        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when trying to update change_email raises an error" do
      it "raises an error" do
        user = create_user(password: "testpass")
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: "user.change@upper.town",
          password: "testpass"
        )

        called = 0
        User.stub_any_instance(:update!, ->(*) { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
          assert_raises(ActiveRecord::ActiveRecordError) do
            described_class.new(change_email_confirmation, user.email).call
          end
        end
        assert_equal(1, called)

        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when trying to update change_email succeeds" do
      it "returns success and enqueues email job" do
        freeze_time do
          user = create_user(password: "testpass")
          change_email_confirmation = Users::ChangeEmailConfirmation.new(
            email: user.email,
            change_email: "user.change@upper.town",
            password: "testpass"
          )

          result = described_class.new(change_email_confirmation, user.email).call

          assert(result.success?)
          assert_equal("user.change@upper.town", result.user.change_email)
          assert_nil(result.user.change_email_confirmed_at)
          assert_enqueued_with(job: Users::ChangeEmailConfirmations::EmailJob, args: [user], at: 30.seconds.from_now)
        end
      end
    end
  end
end
