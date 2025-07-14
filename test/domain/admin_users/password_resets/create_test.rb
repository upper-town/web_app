# frozen_string_literal: true

require "test_helper"

class AdminUsers::PasswordResets::CreateTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::PasswordResets::Create }

  describe "#call" do
    describe "when admin_user is not found" do
      it "returns failure and does not send password reset email" do
        create_admin_user(email: "admin_user@upper.town")

        result = described_class.new("xxx@upper.town").call

        assert(result.failure?)
        assert_nil(result.admin_user)
        assert(result.errors.key?(:admin_user_not_found))
        assert_no_enqueued_jobs(only: AdminUsers::PasswordResets::EmailJob)
      end
    end

    describe "when admin_user is found" do
      it "returns success and sends password reset email" do
        admin_user = create_admin_user(email: "admin_user@upper.town")

        result = described_class.new("admin_user@upper.town").call

        assert(result.success?)
        assert_equal(admin_user, result.admin_user)
        assert_enqueued_with(job: AdminUsers::PasswordResets::EmailJob, args: [admin_user])
      end
    end
  end
end
