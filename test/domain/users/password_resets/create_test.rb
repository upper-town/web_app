# frozen_string_literal: true

require "test_helper"

class Users::PasswordResets::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Users::PasswordResets::Create }

  describe "#call" do
    describe "when user is not found" do
      it "returns success but doesn not enqueue job to send email" do
        _user = create_user(email: "user@upper.town")
        password_reset = Users::PasswordReset.new(email: "xxxxxxxx@upper.town")

        result = described_class.new(password_reset).call

        assert(result.success?)
        assert_no_enqueued_jobs(only: Users::PasswordResets::EmailJob)
      end
    end

    describe "when user is found" do
      it "returns success and enqueues job to send email" do
        user = create_user(email: "user@upper.town")
        password_reset = Users::PasswordReset.new(email: "user@upper.town")

        result = described_class.new(password_reset).call

        assert(result.success?)
        assert_enqueued_with(job: Users::PasswordResets::EmailJob, args: [user])
      end
    end
  end
end
