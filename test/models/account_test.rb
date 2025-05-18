# frozen_string_literal: true

require "test_helper"

class AccountTest < ActiveSupport::TestCase
  let(:described_class) { Account }

  describe "associations" do
    it "belongs to user" do
      account = create_account

      assert(account.user.present?)
    end

    it "has many server_votes" do
      account = create_account
      server_vote1 = create_server_vote(account:)
      server_vote2 = create_server_vote(account:)

      assert_equal(
        [server_vote1, server_vote2].sort,
        account.server_votes.sort
      )
    end

    it "has many server_accounts" do
      account = create_account
      server_account1 = create_server_account(account:)
      server_account2 = create_server_account(account:)

      assert_equal(
        [server_account1, server_account2].sort,
        account.server_accounts.sort
      )
    end

    it "has many servers through server_accounts" do
      account = create_account
      server_account1 = create_server_account(account:)
      server_account2 = create_server_account(account:)

      assert_equal(
        [server_account1.server, server_account2.server].sort,
        account.servers.sort
      )
    end

    it "has many verified_servers through server_accounts" do
      account = create_account
      _server_account1 = create_server_account(account:, verified_at: nil)
      server_account2 = create_server_account(account:, verified_at: Time.current)

      assert_equal(
        [server_account2.server],
        account.verified_servers
      )
    end
  end
end
