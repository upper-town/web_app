require 'rails_helper'

RSpec.describe AdminToken do
  describe 'associations' do
    it 'belongs to admin_user' do
      admin_token = create(:admin_token)

      expect(admin_token.admin_user).to be_present
    end
  end

  describe '.find_by_token' do
    context 'when token value is blank' do
      it 'returns nil' do
        expect(described_class.find_by_token(' ',)).to be_nil
        expect(described_class.find_by_token(' ', true)).to be_nil
      end
    end

    context 'when token is not found by its token_digest' do
      it 'returns nil' do
        expect(described_class.find_by_token('abcdef123456')).to be_nil
        expect(described_class.find_by_token('abcdef123456', true)).to be_nil
      end
    end

    describe 'include_expired false' do
      context 'when token is found by its token_digest but is expired' do
        it 'returns nil' do
          token = 'abcdef123456'
          _existing_admin_token = create(
            :admin_token,
            token_digest: TokenGenerator::Admin.digest(token),
            expires_at: 2.days.ago
          )

          expect(described_class.find_by_token(token)).to be_nil
        end
      end

      context 'when token is found by its token_digest and is not expired' do
        it 'returns Token record' do
          token = 'abcdef123456'
          existing_admin_token = create(
            :admin_token,
            token_digest: TokenGenerator::Admin.digest(token),
            expires_at: 2.days.from_now
          )

          expect(described_class.find_by_token(token)).to eq(existing_admin_token)
        end
      end
    end

    describe 'include_expired true' do
      context 'when token is found by its token_digest' do
        it 'returns AdminToken record' do
          [
            [ 'aaaa1111', 2.days.ago ],
            [ 'bbbb2222', 2.days.from_now ]
          ].each do |token, expires_at|
            existing_admin_token = create(
              :admin_token,
              token_digest: TokenGenerator::Admin.digest(token),
              expires_at: expires_at
            )

            expect(described_class.find_by_token(token, true)).to eq(existing_admin_token)
          end
        end
      end
    end
  end

  describe '.expired' do
    it 'returns expired AdminToken records' do
      freeze_time do
        admin_token1 = create(:admin_token, expires_at: 1.second.ago)
        admin_token2 = create(:admin_token, expires_at: Time.current)
        _admin_token3 = create(:admin_token, expires_at: 1.day.from_now)

        expect(described_class.expired).to contain_exactly(admin_token1, admin_token2)
      end
    end
  end

  describe '.not_expired' do
    it 'returns not expired AdminToken records' do
      freeze_time do
        _admin_token1 = create(:admin_token, expires_at: 1.second.ago)
        _admin_token2 = create(:admin_token, expires_at: Time.current)
        admin_token3 = create(:admin_token, expires_at: 1.day.from_now)

        expect(described_class.not_expired).to contain_exactly(admin_token3)
      end
    end
  end

  describe '#expired?' do
    context 'when expires_at is in the past' do
      it 'returns true' do
        freeze_time do
          admin_token = create(:admin_token, expires_at: 1.second.ago)

          expect(admin_token.expired?).to be(true)
        end
      end
    end

    context 'when expires_at is in the present' do
      it 'returns true' do
        freeze_time do
          admin_token = create(:admin_token, expires_at: Time.current)

          expect(admin_token.expired?).to be(true)
        end
      end
    end

    context 'when expires_at is in the future' do
      it 'returns false' do
        freeze_time do
          admin_token = create(:admin_token, expires_at: 1.second.from_now)

          expect(admin_token.expired?).to be(false)
        end
      end
    end
  end

  describe '#expire!' do
    it 'sets expires_at to the past' do
      freeze_time do
        admin_token = create(:admin_token, expires_at: 1.day.from_now)

        admin_token.expire!

        expect(admin_token.expires_at).to eq(1.day.ago)
      end
    end
  end
end
