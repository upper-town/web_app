# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Session do
  describe 'associations' do
    it 'belongs to user' do
      session = create(:session)

      expect(session.user).to be_present
    end
  end

  describe '.find_by_token' do
    context 'when token is blank' do
      it 'returns nil' do
        expect(described_class.find_by_token(' ')).to be_nil
      end
    end

    context 'when Session is not found' do
      it 'returns nil' do
        expect(described_class.find_by_token('abcdef123456')).to be_nil
      end
    end

    context 'when Session is found' do
      it 'returns Session record' do
        session = create(:session, token_digest: TokenGenerator::Session.digest('abcdef123456'))

        expect(described_class.find_by_token('abcdef123456')).to eq(session)
      end
    end
  end

  describe '#expired?' do
    context 'when expires_at is the current time' do
      it 'returns true' do
        freeze_time do
          session = create(:session, expires_at: Time.current)

          expect(session.expired?).to be(true)
        end
      end
    end

    context 'when expires_at is less than the current time' do
      it 'returns true' do
        freeze_time do
          session = create(:session, expires_at: 1.second.ago)

          expect(session.expired?).to be(true)
        end
      end
    end

    context 'when expires_at is greater than the current time' do
      it 'returns false' do
        freeze_time do
          session = create(:session, expires_at: 1.second.from_now)

          expect(session.expired?).to be(false)
        end
      end
    end
  end
end
