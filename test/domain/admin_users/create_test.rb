# frozen_string_literal: true

require "test_helper"

class AdminUsers::CreateTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::Create }

  describe "#call" do
    describe "when rate_limiter has been exceeded" do
      it "returns failure" do
        email_confirmation = AdminUsers::EmailConfirmation.new(email: "admin.user@upper.town")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "admin_users_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(email_confirmation, request).call

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/Too many requests/) })
        assert_equal(4, Rails.cache.read(rate_limiter_key))
        assert_no_enqueued_jobs(only: AdminUsers::EmailConfirmations::EmailJob)
      end
    end

    describe "when admin_user does not exist" do
      it "returns success, creates admin_user and sends email confirmation" do
        email_confirmation = AdminUsers::EmailConfirmation.new(email: "admin.user@upper.town")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "admin_users_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = nil
        assert_difference(-> { AdminUser.count }, 1) do
          assert_difference(-> { AdminAccount.count }, 1) do
            result = described_class.new(email_confirmation, request).call
          end
        end

        admin_user = AdminUser.last
        admin_account = AdminAccount.last
        assert_equal("admin.user@upper.town", admin_user.email)
        assert(admin_user.account.present?)
        assert_equal(admin_account, admin_user.account)
        assert(admin_user.email_confirmed_at.blank?)

        assert(result.success?)
        assert_equal(1, Rails.cache.read(rate_limiter_key))
        assert_enqueued_with(job: AdminUsers::EmailConfirmations::EmailJob, args: [admin_user])
      end

      describe "when an error is raised trying to create admin_user" do
        it "raises error and uncalls rate_limiter" do
          email_confirmation = AdminUsers::EmailConfirmation.new(email: "admin.user@upper.town")
          request = build_request(remote_ip: "1.1.1.1")
          rate_limiter_key = "admin_users_create:1.1.1.1"
          Rails.cache.write(rate_limiter_key, 0)

          called = 0
          AdminUser.stub_any_instance(:save!, -> { called += 1 ; ActiveRecord::ActiveRecordError }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(email_confirmation, request).call
            end
          end
          assert_equal(1, called)

          assert_equal(0, Rails.cache.read(rate_limiter_key))
          assert_no_enqueued_jobs(only: AdminUsers::EmailConfirmations::EmailJob)
        end
      end
    end

    describe "when admin_user already exists" do
      it "returns success, finds admin_user and sends email confirmation" do
        admin_user = create_admin_user(email: "admin.user@upper.town")
        email_confirmation = AdminUsers::EmailConfirmation.new(email: "admin.user@upper.town")
        request = build_request(remote_ip: "1.1.1.1")
        rate_limiter_key = "admin_users_create:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 0)

        result = nil
        assert_difference(-> { AdminUser.count }, 0) do
          assert_difference(-> { AdminAccount.count }, 0) do
            result = described_class.new(email_confirmation, request).call
          end
        end

        assert(result.success?)
        assert_equal(1, Rails.cache.read(rate_limiter_key))
        assert_enqueued_with(job: AdminUsers::EmailConfirmations::EmailJob, args: [admin_user])
      end
    end
  end
end
