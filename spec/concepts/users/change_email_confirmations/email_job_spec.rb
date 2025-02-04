# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::ChangeEmailConfirmations::EmailJob do
  describe '#perform' do
    it 'generates tokens and sends them in the emails' do
      freeze_time do
        user = create(:user, email: 'user@upper.town', change_email: 'user.change@upper.town')

        expect do
          described_class.new.perform(user)
        end.to(
          change(Token, :count).by(2).and(
            change(ActionMailer::Base.deliveries, :count).by(2)
          )
        )

        token1 = Token.find_by!(purpose: 'change_email_reversion')
        expect(token1.expires_at).to eq(30.days.from_now)
        expect(token1.data).to eq({ 'email' => 'user@upper.town' })

        token2 = Token.find_by!(purpose: 'change_email_confirmation')
        expect(token2.expires_at).to eq(1.hour.from_now)
        expect(token2.data).to eq({ 'change_email' => 'user.change@upper.town' })

        user.reload
        expect(user.change_email_reversion_sent_at).to eq(Time.current)
        expect(user.change_email_confirmation_sent_at).to eq(Time.current)

        mail_message1 = ActionMailer::Base.deliveries.find { |mail_message| mail_message.subject.include?('Change email reversion link') }
        expect(mail_message1.from).to eq(['noreply@test.upper.town'])
        expect(mail_message1.to).to eq(['user@upper.town'])
        expect(mail_message1.body).to match(%r"users/change_email_reversion/edit\?auto_click=true&amp;token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}")

        mail_message2 = ActionMailer::Base.deliveries.find { |mail_message| mail_message.subject.include?('Change email confirmation link') }
        expect(mail_message2.from).to eq(['noreply@test.upper.town'])
        expect(mail_message2.to).to eq(['user.change@upper.town'])
        expect(mail_message2.body).to match(%r"users/change_email_confirmation/edit\?auto_click=true&amp;token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}")
      end
    end
  end
end
