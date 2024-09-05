# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUsers::EmailConfirmations::EmailJob do
  describe '#perform' do
    context 'when admin_user is not found' do
      it 'raises an error' do
        expect do
          described_class.new.perform(0)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when admin_user is found' do
      it 'generates token and sends it in the email' do
        freeze_time do
          admin_user = create(:admin_user)

          expect do
            described_class.new.perform(admin_user.id)
          end.to(
            change(AdminToken, :count).by(1).and(
              change(ActionMailer::Base.deliveries, :count).by(1)
            )
          )

          admin_token = AdminToken.last
          expect(admin_token.purpose).to eq('email_confirmation')
          expect(admin_token.expires_at).to eq(1.hour.from_now)

          mail_message = ActionMailer::Base.deliveries.last
          expect(mail_message.from).to eq(['noreply@test.upper.town'])
          expect(mail_message.to).to eq([admin_user.email])
          expect(mail_message.subject).to include('Email confirmation link')
          expect(mail_message.body).to match(%r"admin_users/email_confirmation/edit\?auto_click=true&amp;token=[ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789]{48}")

          expect(admin_user.reload.email_confirmation_sent_at).to eq(Time.current)
        end
      end
    end
  end
end
