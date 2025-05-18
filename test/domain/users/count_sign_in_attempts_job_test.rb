# frozen_string_literal: true

require "test_helper"

class Users::CountSignInAttemptsJobTest < ActiveSupport::TestCase
  let(:described_class) { Users::CountSignInAttemptsJob }

  describe "#perform" do
    describe "when User is not found" do
      it "does not raise an error" do
        assert_nothing_raised do
          described_class.new.perform("nobody@upper.town", true)
        end
      end
    end

    describe "when User is found" do
      describe "when suceeded is true" do
        it "increments sign_in_count" do
          user = create_user(sign_in_count: 1, failed_attempts: 1)

          described_class.new.perform(user.email, true)

          user.reload
          assert_equal(2, user.sign_in_count)
          assert_equal(1, user.failed_attempts)
        end
      end

      describe "when suceeded is false" do
        it "increments failed_attempts" do
          user = create_user(sign_in_count: 1, failed_attempts: 1)

          described_class.new.perform(user.email, false)

          user.reload
          assert_equal(1, user.sign_in_count)
          assert_equal(2, user.failed_attempts)
        end
      end
    end
  end
end
