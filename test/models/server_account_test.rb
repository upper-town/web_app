# frozen_string_literal: true

require "test_helper"

class ServerAccountTest < ActiveSupport::TestCase
  let(:described_class) { ServerAccount }

  describe "associations" do
    it "belongs to server" do
      server_account = create_server_account

      assert(server_account.server.present?)
    end

    it "belongs to account" do
      server_account = create_server_account

      assert(server_account.account.present?)
    end
  end

  describe ".verified" do
    it "returns verified server_accounts" do
      _server_account1 = create_server_account(verified_at: nil)
      server_account2 = create_server_account(verified_at: Time.current)

      assert_equal(
        [server_account2],
        described_class.verified
      )
    end
  end

  describe ".not_verified" do
    it "returns not verified server_accounts" do
      server_account1 = create_server_account(verified_at: nil)
      _server_account2 = create_server_account(verified_at: Time.current)

      assert_equal(
        [server_account1],
        described_class.not_verified
      )
    end
  end

  describe "verified?" do
    describe "when verified_at is present" do
      it "returns true" do
        server_account = create_server_account(verified_at: Time.current)

        assert(server_account.verified?)
      end
    end

    describe "when verified_at is blank" do
      it "returns false" do
        server_account = create_server_account(verified_at: nil)

        assert_not(server_account.verified?)
      end
    end
  end

  describe "not_verified?" do
    describe "when verified_at is present" do
      it "returns false" do
        server_account = create_server_account(verified_at: Time.current)

        assert_not(server_account.not_verified?)
      end
    end

    describe "when verified_at is blank" do
      it "returns true" do
        server_account = create_server_account(verified_at: nil)

        assert(server_account.not_verified?)
      end
    end
  end
end
