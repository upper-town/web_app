# frozen_string_literal: true

require "test_helper"

class Users::PasswordResets::EmailJobTest < ActiveSupport::TestCase
  let(:described_class) { Users::PasswordResets::EmailJob }

  describe "#perform" do
    it "generates token and sends it in the email" do
      freeze_time do
        user = create_user

        assert_difference(-> { Token.count }, 1) do
          assert_difference(-> { ActionMailer::Base.deliveries.count }, 1) do
            described_class.new.perform(user)
          end
        end

        token = Token.last
        assert_equal("password_reset", token.purpose)
        assert_equal(1.hour.from_now, token.expires_at)

        mail_message = ActionMailer::Base.deliveries.last
        assert_equal(["noreply@test.upper.town"], mail_message.from)
        assert_equal([user.email], mail_message.to)
        assert_includes(mail_message.subject, "Password Reset Email")
        assert_match(%r"users/password_reset/edit\?token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}", mail_message.body.to_s)

        assert_equal(Time.current, user.reload.password_reset_sent_at)
      end
    end
  end
end
