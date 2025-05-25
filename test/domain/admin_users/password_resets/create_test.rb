# frozen_string_literal: true

require "test_helper"

class AdminUsers::PasswordResets::CreateTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::PasswordResets::Create }

  describe "#call" do
    describe "when admin_user is not found" do
      it "returns success but doesn not enqueue job to send email" do
        _admin_user = create_admin_user(email: "admin_user@upper.town")
        password_reset = AdminUsers::PasswordReset.new(email: "xxxxxxxx@upper.town")

        result = described_class.new(password_reset).call

        assert(result.success?)
        assert_no_enqueued_jobs(only: AdminUsers::PasswordResets::EmailJob)
      end
    end

    describe "when admin_user is found" do
      it "returns success and enqueues job to send email" do
        admin_user = create_admin_user(email: "admin_user@upper.town")
        password_reset = AdminUsers::PasswordReset.new(email: "admin_user@upper.town")

        result = described_class.new(password_reset).call

        assert(result.success?)
        assert_enqueued_with(job: AdminUsers::PasswordResets::EmailJob, args: [admin_user])
      end
    end
  end
end
