require 'rails_helper'

RSpec.describe AdminUsers::CountSignInAttemptsJob do
  describe '#perform' do
    context 'when AdminUser is not found' do
      it 'does not raise an error' do
        expect do
          described_class.new.perform('nobody@upper.town', true)
        end.not_to raise_error
      end
    end

    context 'when AdminUser is found' do
      context 'when suceeded is true' do
        it 'increments sign_in_count' do
          admin_user = create(:admin_user, sign_in_count: 1, failed_attempts: 1)

          described_class.new.perform(admin_user.email, true)

          admin_user.reload
          expect(admin_user.sign_in_count).to eq(2)
          expect(admin_user.failed_attempts).to eq(1)
        end
      end

      context 'when suceeded is false' do
        it 'increments failed_attempts' do
          admin_user = create(:admin_user, sign_in_count: 1, failed_attempts: 1)

          described_class.new.perform(admin_user.email, false)

          admin_user.reload
          expect(admin_user.sign_in_count).to eq(1)
          expect(admin_user.failed_attempts).to eq(2)
        end
      end
    end
  end
end
