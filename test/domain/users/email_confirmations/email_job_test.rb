# frozen_string_literal: true

require "test_helper"

class Users::EmailConfirmations::EmailJobTest < ActiveSupport::TestCase
  let(:described_class) { Users::EmailConfirmations::EmailJob }

  describe "#perform" do
    it "generates code and sends it in the email" do
      freeze_time do
        user = create_user

        assert_difference(-> { Code.count }, 1) do
          assert_difference(-> { ActionMailer::Base.deliveries.count }, 1) do
            described_class.new.perform(user)
          end
        end

        code = Code.last
        assert_equal("email_confirmation", code.purpose)
        assert_equal(30.minutes.from_now, code.expires_at)

        mail_message = ActionMailer::Base.deliveries.last
        assert_equal([ENV.fetch("NOREPLY_EMAIL")], mail_message.from)
        assert_equal([user.email], mail_message.to)
        assert_includes(mail_message.subject, "Email Confirmation: verification code")
        assert_match(/[ABCDEFGHJKLMNPQRSTUWXYZ123456789]{8}/, mail_message.body.to_s)

        assert_equal(Time.current, user.reload.email_confirmation_sent_at)
      end
    end
  end
end
