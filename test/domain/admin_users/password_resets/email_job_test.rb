# frozen_string_literal: true

require "test_helper"

class AdminUsers::PasswordResets::EmailJobTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::PasswordResets::EmailJob }

  describe "#perform" do
    it "generates code and sends it in the email" do
      freeze_time do
        admin_user = create_admin_user

        assert_difference(-> { AdminCode.count }, 1) do
          assert_difference(-> { ActionMailer::Base.deliveries.count }, 1) do
            described_class.new.perform(admin_user)
          end
        end

        admin_code = AdminCode.last
        assert_equal("password_reset", admin_code.purpose)
        assert_equal(30.minutes.from_now, admin_code.expires_at)

        mail_message = ActionMailer::Base.deliveries.last
        assert_equal([ENV.fetch("NOREPLY_EMAIL")], mail_message.from)
        assert_equal([admin_user.email], mail_message.to)
        assert_includes(mail_message.subject, "Password Reset: verification code")
        assert_match(/\b[ABCDEFGHJKLMNPQRSTUWXYZ123456789]{8}\b/, mail_message.body.to_s)

        assert_equal(Time.current, admin_user.reload.password_reset_sent_at)
      end
    end
  end
end
