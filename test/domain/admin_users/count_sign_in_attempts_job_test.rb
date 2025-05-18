# frozen_string_literal: true

require "test_helper"

class AdminUsers::CountSignInAttemptsJobTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::CountSignInAttemptsJob }

  describe "#perform" do
    describe "when AdminUser is not found" do
      it "does not raise an error" do
        assert_nothing_raised do
          described_class.new.perform("nobody@upper.town", true)
        end
      end
    end

    describe "when AdminUser is found" do
      describe "when suceeded is true" do
        it "increments sign_in_count" do
          admin_user = create_admin_user(sign_in_count: 1, failed_attempts: 1)

          described_class.new.perform(admin_user.email, true)

          admin_user.reload
          assert_equal(2, admin_user.sign_in_count)
          assert_equal(1, admin_user.failed_attempts)
        end
      end

      describe "when suceeded is false" do
        it "increments failed_attempts" do
          admin_user = create_admin_user(sign_in_count: 1, failed_attempts: 1)

          described_class.new.perform(admin_user.email, false)

          admin_user.reload
          assert_equal(1, admin_user.sign_in_count)
          assert_equal(2, admin_user.failed_attempts)
        end
      end
    end
  end
end
