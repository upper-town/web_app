# frozen_string_literal: true

require "test_helper"

class Users::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Users::Create }

  describe "#call" do
    describe "when rate_limiter has been exceeded" do
      it "returns failure" do
        email_confirmation = Users::EmailConfirmation.new(email: "user@upper.town")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(email_confirmation, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Too many requests/) })
        assert_equal(4, Rails.cache.read(rate_limiter_key))
        assert_no_enqueued_jobs(only: Users::EmailConfirmations::EmailJob)
      end
    end

    describe "when user does not exist" do
      it "returns success, creates user and sends email confirmation" do
        email_confirmation = Users::EmailConfirmation.new(email: "user@upper.town")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = nil
        assert_difference(-> { User.count }, 1) do
          assert_difference(-> { Account.count }, 1) do
            result = described_class.new(email_confirmation, request).call
          end
        end

        user = User.last
        account = Account.last
        assert_equal("user@upper.town", user.email)
        assert(user.account.present?)
        assert_equal(account, user.account)
        assert(user.email_confirmed_at.blank?)

        assert(result.success?)
        assert_equal(1, Rails.cache.read(rate_limiter_key))
        assert_enqueued_with(job: Users::EmailConfirmations::EmailJob, args: [user])
      end

      describe "when an error is raised trying to create user" do
        it "raises error and uncalls rate_limiter" do
          email_confirmation = Users::EmailConfirmation.new(email: "user@upper.town")
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "users_create:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          called = 0
          User.stub_any_instance(:save!, -> { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(email_confirmation, request).call
            end
          end
          assert_equal(1, called)

          assert_equal(0, Rails.cache.read(rate_limiter_key))
          assert_no_enqueued_jobs(only: Users::EmailConfirmations::EmailJob)
        end
      end
    end

    describe "when user already exists" do
      it "returns success, finds user and sends email confirmation" do
        user = create_user(email: "user@upper.town")
        email_confirmation = Users::EmailConfirmation.new(email: "user@upper.town")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "users_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = nil
        assert_no_difference(-> { User.count }) do
          assert_no_difference(-> { Account.count }) do
            result = described_class.new(email_confirmation, request).call
          end
        end

        assert(result.success?)
        assert_equal(1, Rails.cache.read(rate_limiter_key))
        assert_enqueued_with(job: Users::EmailConfirmations::EmailJob, args: [user])
      end
    end
  end
end
