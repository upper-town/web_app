# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailConfirmations::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailConfirmations::Create }

  describe "#call" do
    describe "when current_user_email is different than the email provided" do
      it "returns failure" do
        user = create_user(email: "user@upper.town",  password: "testpass")

        email = "someone.else@upper.town"
        change_email = "user.new@upper.town"
        password = "testpass"

        result = described_class.new(email, change_email, password, user.email).call

        assert(result.failure?)
        assert_nil(result.user)
        assert(result.errors.key?(:incorrect_current_email))
        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when password is incorrect" do
      it "returns failure and fails to authenticate user" do
        user = create_user(email: "user@upper.town",  password: "testpass")

        email = user.email
        change_email = "user.new@upper.town"
        password = "xxxxxxxx"

        result = described_class.new(email, change_email, password, user.email).call

        assert(result.failure?)
        assert_nil(result.user)
        assert(result.errors.key?(:incorrect_password_or_email))
        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when trying to update change_email raises an error" do
      it "raises an error" do
        user = create_user(email: "user@upper.town",  password: "testpass", change_email_confirmed_at: Time.current)

        email = user.email
        change_email = "user.new@upper.town"
        password = "testpass"

        called = 0
        User.stub_any_instance(:update!, ->(*) { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
          assert_raises(ActiveRecord::ActiveRecordError) do
            described_class.new(email, change_email, password, user.email).call
          end
        end
        assert_equal(1, called)

        assert(user.change_email_confirmed_at.present?)
        assert_no_enqueued_jobs(only: Users::ChangeEmailConfirmations::EmailJob)
      end
    end

    describe "when trying to update change_email succeeds" do
      it "returns success and enqueues email job" do
        user = create_user(email: "user@upper.town",  password: "testpass", change_email_confirmed_at: Time.current)

        email = user.email
        change_email = "user.new@upper.town"
        password = "testpass"

        result = described_class.new(email, change_email, password, user.email).call

        assert(result.success?)
        assert_equal(user, result.user)
        assert_equal("user.new@upper.town", result.user.change_email)
        assert_nil(result.user.change_email_confirmed_at)
        assert_enqueued_with(job: Users::ChangeEmailConfirmations::EmailJob, args: [user])
      end
    end
  end
end
