require 'rails_helper'

RSpec.describe ServerAccount do
  describe 'associations' do
    it 'belongs to server' do
      server_account = create(:server_account)

      expect(server_account.server).to be_present
    end

    it 'belongs to account' do
      server_account = create(:server_account)

      expect(server_account.account).to be_present
    end
  end

  describe '.verified' do
    it 'returns verified server_accounts' do
      _server_account1 = create(:server_account, verified_at: nil)
      server_account2 = create(:server_account, verified_at: Time.current)

      expect(described_class.verified).to contain_exactly(server_account2)
    end
  end

  describe '.not_verified' do
    it 'returns not verified server_accounts' do
      server_account1 = create(:server_account, verified_at: nil)
      _server_account2 = create(:server_account, verified_at: Time.current)

      expect(described_class.not_verified).to contain_exactly(server_account1)
    end
  end

  describe 'verified?' do
    context 'when verified_at is present' do
      it 'returns true' do
        server_account = create(:server_account, verified_at: Time.current)

        expect(server_account.verified?).to be(true)
      end
    end

    context 'when verified_at is blank' do
      it 'returns false' do
        server_account = create(:server_account, verified_at: nil)

        expect(server_account.verified?).to be(false)
      end
    end
  end

  describe 'not_verified?' do
    context 'when verified_at is present' do
      it 'returns false' do
        server_account = create(:server_account, verified_at: Time.current)

        expect(server_account.not_verified?).to be(false)
      end
    end

    context 'when verified_at is blank' do
      it 'returns true' do
        server_account = create(:server_account, verified_at: nil)

        expect(server_account.not_verified?).to be(true)
      end
    end
  end
end
