# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailConfirmations::EmailJobTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailConfirmations::EmailJob }

  describe "#perform" do
    it "generates token and codes and sends them in the emails" do
      freeze_time do
        user = create_user(email: "user@upper.town", change_email: "user.new@upper.town")

        assert_difference(-> { Token.count }, 1) do
          assert_difference(-> { Code.count }, 2) do
            assert_difference(-> { ActionMailer::Base.deliveries.count }, 2) do
              perform_enqueued_jobs do
                described_class.new.perform(user)
              end
            end
          end
        end

        token = Token.find_by!(purpose: :change_email_reversion)
        assert_equal(30.days.from_now, token.expires_at)
        assert_equal({}, token.data)

        code1 = Code.find_by!(purpose: :change_email_reversion)
        assert_equal(30.days.from_now, code1.expires_at)
        assert_equal({ "email" => "user@upper.town" }, code1.data)

        code2 = Code.find_by!(purpose: :change_email_confirmation)
        assert_equal(30.minutes.from_now, code2.expires_at)
        assert_equal({ "change_email" => "user.new@upper.town" }, code2.data)

        user.reload
        assert_equal(Time.current, user.change_email_reversion_sent_at)
        assert_equal(Time.current, user.change_email_confirmation_sent_at)

        mail_message1 = ActionMailer::Base.deliveries.find { |mail_message| mail_message.subject.include?("Change Email: reversion link") }
        assert_equal([ENV.fetch("NOREPLY_EMAIL")], mail_message1.from)
        assert_equal(["user@upper.town"], mail_message1.to)
        assert_match(%r"/users/change_email_reversion/edit\?token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{44}", mail_message1.body.to_s)
        assert_match(/\b[ABCDEFGHJKLMNPQRSTUWXYZ123456789]{8}\b/, mail_message1.body.to_s)

        mail_message2 = ActionMailer::Base.deliveries.find { |mail_message| mail_message.subject.include?("Change Email: verification code") }
        assert_equal([ENV.fetch("NOREPLY_EMAIL")], mail_message2.from)
        assert_equal(["user.new@upper.town"], mail_message2.to)
        assert_match(/\b[ABCDEFGHJKLMNPQRSTUWXYZ123456789]{8}\b/, mail_message2.body.to_s)
      end
    end
  end
end
