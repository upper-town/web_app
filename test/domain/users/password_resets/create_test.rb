# frozen_string_literal: true

require "test_helper"

class Users::PasswordResets::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Users::PasswordResets::Create }

  describe "#call" do
    describe "when user is not found" do
      it "returns failure and does not send password reset email" do
        create_user(email: "user@upper.town")

        result = described_class.new("xxx@upper.town").call

        assert(result.failure?)
        assert_nil(result.user)
        assert(result.errors.key?(:user_not_found))
        assert_no_enqueued_jobs(only: Users::PasswordResets::EmailJob)
      end
    end

    describe "when user is found" do
      it "returns success and sends password reset email" do
        user = create_user(email: "user@upper.town")

        result = described_class.new("user@upper.town").call

        assert(result.success?)
        assert_equal(user, result.user)
        assert_enqueued_with(job: Users::PasswordResets::EmailJob, args: [user])
      end
    end
  end
end
