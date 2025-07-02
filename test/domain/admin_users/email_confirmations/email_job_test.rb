# frozen_string_literal: true

require "test_helper"

class AdminUsers::EmailConfirmations::EmailJobTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::EmailConfirmations::EmailJob }

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
        assert_equal("email_confirmation", admin_token.purpose)
        assert_equal(1.hour.from_now, admin_token.expires_at)

        mail_message = ActionMailer::Base.deliveries.last
        assert_equal(["noreply@uppertown.test"], mail_message.from)
        assert_equal([admin_user.email], mail_message.to)
        assert_includes(mail_message.subject, "Email confirmation link")
        assert_match(
          %r"admin_users/email_confirmation/edit\?auto_click=true&amp;token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}",
          mail_message.body.to_s
        )

        assert_equal(Time.current, admin_user.reload.email_confirmation_sent_at)
      end
    end
  end
end
