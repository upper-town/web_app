require 'rails_helper'

RSpec.describe Users::EmailConfirmations::EmailJob do
  describe '#perform' do
    it 'generates token and sends it in the email' do
      freeze_time do
        user = create(:user)

        expect do
          described_class.new.perform(user)
        end.to(
          change(Token, :count).by(1).and(
            change(ActionMailer::Base.deliveries, :count).by(1)
          )
        )

        token = Token.last
        expect(token.purpose).to eq('email_confirmation')
        expect(token.expires_at).to eq(1.hour.from_now)

        mail_message = ActionMailer::Base.deliveries.last
        expect(mail_message.from).to eq([ 'noreply@test.upper.town' ])
        expect(mail_message.to).to eq([ user.email ])
        expect(mail_message.subject).to include('Email confirmation link')
        expect(mail_message.body).to match(%r"users/email_confirmation/edit\?auto_click=true&amp;token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}")

        expect(user.reload.email_confirmation_sent_at).to eq(Time.current)
      end
    end
  end
end
