# frozen_string_literal: true

require "test_helper"

class ServerVoteTest < ActiveSupport::TestCase
  let(:described_class) { ServerVote }

  describe "associations" do
    it "belongs to server" do
      server_vote = create_server_vote

      assert(server_vote.server.present?)
    end

    it "belongs to game" do
      server_vote = create_server_vote

      assert(server_vote.game.present?)
    end

    it "belongs to account optionally" do
      server_vote = create_server_vote

      assert(server_vote.account.blank?)

      server_vote = create_server_vote(account: create_account)

      assert(server_vote.account.present?)
    end
  end

  describe "validations" do
    it "validates country_code" do
      server_vote = build_server_vote(country_code: "123456")
      server_vote.validate

      assert(server_vote.errors.of_kind?(:country_code, :inclusion))
    end

    it "validates server_available" do
      server = create_server(archived_at: Time.current)
      server_vote = build_server_vote(server:)
      server_vote.validate

      assert(server_vote.errors.of_kind?(:server, "cannot be archived"))

      server = create_server(marked_for_deletion_at: Time.current)
      server_vote = build_server_vote(server:)
      server_vote.validate

      assert(server_vote.errors.of_kind?(:server, "cannot be marked_for_deletion"))

      server = create_server
      server_vote = build_server_vote(server:)
      server_vote.validate

      assert_not(server_vote.errors.key?(:server))
    end
  end
end
