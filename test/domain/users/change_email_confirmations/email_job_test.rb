# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailConfirmations::EmailJobTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailConfirmations::EmailJob }

  describe "#perform" do
    it "generates tokens and sends them in the emails" do
      freeze_time do
        user = create_user(email: "user@upper.town", change_email: "user.change@upper.town")

        assert_difference(-> { Token.count }, 2) do
          assert_difference(-> { ActionMailer::Base.deliveries.count }, 2) do
            described_class.new.perform(user)
          end
        end

        token1 = Token.find_by!(purpose: "change_email_reversion")
        assert_equal(30.days.from_now, token1.expires_at)
        assert_equal({ "email" => "user@upper.town" }, token1.data)

        token2 = Token.find_by!(purpose: "change_email_confirmation")
        assert_equal(1.hour.from_now, token2.expires_at)
        assert_equal({ "change_email" => "user.change@upper.town" }, token2.data)

        user.reload
        assert_equal(Time.current, user.change_email_reversion_sent_at)
        assert_equal(Time.current, user.change_email_confirmation_sent_at)

        mail_message1 = ActionMailer::Base.deliveries.find { |mail_message| mail_message.subject.include?("Change email reversion link") }
        assert_equal(["noreply@test.upper.town"], mail_message1.from)
        assert_equal(["user@upper.town"], mail_message1.to)
        assert_match(%r"users/change_email_reversion/edit\?auto_click=true&amp;token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}", mail_message1.body.to_s)

        mail_message2 = ActionMailer::Base.deliveries.find { |mail_message| mail_message.subject.include?("Change email confirmation link") }
        assert_equal(["noreply@test.upper.town"], mail_message2.from)
        assert_equal(["user.change@upper.town"], mail_message2.to)
        assert_match(%r"users/change_email_confirmation/edit\?auto_click=true&amp;token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}", mail_message2.body.to_s)
      end
    end
  end
end
