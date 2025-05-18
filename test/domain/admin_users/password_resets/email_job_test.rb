# frozen_string_literal: true

require "test_helper"

class AdminUsers::PasswordResets::EmailJobTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::PasswordResets::EmailJob }

  describe "#perform" do
    it "generates token and sends it in the email" do
      freeze_time do
        admin_user = create_admin_user

        assert_difference(-> { AdminToken.count }, 1) do
          assert_difference(-> { ActionMailer::Base.deliveries.count }, 1) do
            described_class.new.perform(admin_user)
          end
        end

        admin_token = AdminToken.last
        assert_equal("password_reset", admin_token.purpose)
        assert_equal(1.hour.from_now, admin_token.expires_at)

        mail_message = ActionMailer::Base.deliveries.last
        assert_equal(["noreply@test.upper.town"], mail_message.from)
        assert_equal([admin_user.email], mail_message.to)
        assert_includes(mail_message.subject, "Password Reset Email")
        assert_match(
          %r"admin_users/password_reset/edit\?token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}",
          mail_message.body.to_s
        )

        assert_equal(Time.current, admin_user.reload.password_reset_sent_at)
      end
    end
  end
end
