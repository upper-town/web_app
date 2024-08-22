# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Token do
  describe 'associations' do
    it 'belongs to user' do
      token = create(:token)

      expect(token.user).to be_present
    end
  end

  describe '.find_by_token' do
    context 'when token value is blank' do
      it 'returns nil' do
        token = described_class.find_by_token(' ')

        expect(token).to be_nil
      end
    end

    context 'when token is not found by its token_digest' do
      it 'returns nil' do
        token = described_class.find_by_token('abcdef123456')

        expect(token).to be_nil
      end
    end

    context 'when token is found by its token_digest' do
      it 'return Token record' do
        existing_token = create(
          :token,
          token_digest: TokenGenerator.digest('abcdef123456')
        )
        token = described_class.find_by_token('abcdef123456')

        expect(token).to eq(existing_token)
      end
    end
  end

  describe '.expired' do
    it 'returns expired Token records' do
      freeze_time do
        token1 = create(:token, expires_at: 1.second.ago)
        token2 = create(:token, expires_at: Time.current)
        _token3 = create(:token, expires_at: 1.day.from_now)

        expect(described_class.expired).to contain_exactly(token1, token2)
      end
    end
  end

  describe '.not_expired' do
    it 'returns not expired Token records' do
      freeze_time do
        _token1 = create(:token, expires_at: 1.second.ago)
        _token2 = create(:token, expires_at: Time.current)
        token3 = create(:token, expires_at: 1.day.from_now)

        expect(described_class.not_expired).to contain_exactly(token3)
      end
    end
  end

  describe '#expired?' do
    context 'when expires_at is in the past' do
      it 'returns true' do
        freeze_time do
          token = create(:token, expires_at: 1.second.ago)

          expect(token.expired?).to be(true)
        end
      end
    end

    context 'when expires_at is in the present' do
      it 'returns true' do
        freeze_time do
          token = create(:token, expires_at: Time.current)

          expect(token.expired?).to be(true)
        end
      end
    end

    context 'when expires_at is in the future' do
      it 'returns false' do
        freeze_time do
          token = create(:token, expires_at: 1.second.from_now)

          expect(token.expired?).to be(false)
        end
      end
    end
  end

  describe '#expire!' do
    it 'sets expires_at to the past' do
      freeze_time do
        token = create(:token, expires_at: 1.day.from_now)

        token.expire!

        expect(token.expires_at).to eq(1.day.ago)
      end
    end
  end
end
