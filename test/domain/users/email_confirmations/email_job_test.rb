# frozen_string_literal: true

require "test_helper"

class Users::EmailConfirmations::EmailJobTest < ActiveSupport::TestCase
  let(:described_class) { Users::EmailConfirmations::EmailJob }

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
        assert_equal("email_confirmation", token.purpose)
        assert_equal(1.hour.from_now, token.expires_at)

        mail_message = ActionMailer::Base.deliveries.last
        assert_equal(["noreply@test.upper.town"], mail_message.from)
        assert_equal([user.email], mail_message.to)
        assert_includes(mail_message.subject, "Email confirmation link")
        assert_match(%r"users/email_confirmation/edit\?auto_click=true&amp;token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}", mail_message.body.to_s)

        assert_equal(Time.current, user.reload.email_confirmation_sent_at)
      end
    end
  end
end
