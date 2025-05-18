require 'rails_helper'

RSpec.describe Account do
  describe 'associations' do
    it 'belongs to user' do
      account = create(:account)

      expect(account.user).to be_present
    end

    it 'has many server_votes' do
      account = create(:account)
      server_vote1 = create(:server_vote, account: account)
      server_vote2 = create(:server_vote, account: account)

      expect(account.server_votes).to contain_exactly(server_vote1, server_vote2)
    end

    it 'has many server_accounts' do
      account = create(:account)
      server_account1 = create(:server_account, account: account)
      server_account2 = create(:server_account, account: account)

      expect(account.server_accounts).to contain_exactly(server_account1, server_account2)
    end

    it 'has many servers through server_accounts' do
      account = create(:account)
      server_account1 = create(:server_account, account: account)
      server_account2 = create(:server_account, account: account)

      expect(account.servers).to contain_exactly(server_account1.server, server_account2.server)
    end

    it 'has many verified_servers through server_accounts' do
      account = create(:account)
      _server_account1 = create(:server_account, account: account, verified_at: nil)
      server_account2 = create(:server_account, account: account, verified_at: Time.current)

      expect(account.verified_servers).to contain_exactly(server_account2.server)
    end
  end
end
