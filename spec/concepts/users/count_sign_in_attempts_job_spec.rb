require 'rails_helper'

RSpec.describe Users::CountSignInAttemptsJob do
  describe '#perform' do
    context 'when User is not found' do
      it 'does not raise an error' do
        expect do
          described_class.new.perform('nobody@upper.town', true)
        end.not_to raise_error
      end
    end

    context 'when User is found' do
      context 'when suceeded is true' do
        it 'increments sign_in_count' do
          user = create(:user, sign_in_count: 1, failed_attempts: 1)

          described_class.new.perform(user.email, true)

          user.reload
          expect(user.sign_in_count).to eq(2)
          expect(user.failed_attempts).to eq(1)
        end
      end

      context 'when suceeded is false' do
        it 'increments failed_attempts' do
          user = create(:user, sign_in_count: 1, failed_attempts: 1)

          described_class.new.perform(user.email, false)

          user.reload
          expect(user.sign_in_count).to eq(1)
          expect(user.failed_attempts).to eq(2)
        end
      end
    end
  end
end
