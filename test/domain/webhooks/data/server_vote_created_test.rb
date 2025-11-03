# frozen_string_literal: true

require "test_helper"

class Webhooks::Data::ServerVoteCreatedTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::Data::ServerVoteCreated }

  describe "#call" do
    it "returns hash with server_vote data" do
      game = create_game
      server = create_server

      server_vote1 = create_server_vote(
        game:,
        server:,
        reference: "anything123456",
        remote_ip: "1.1.1.1",
        account: nil,
        created_at: Time.iso8601("2024-09-02T12:00:01Z")
      )
      returned = described_class.new(server_vote1).call

      assert_equal(
        {
          "server_vote" => {
            "uuid"         => server_vote1.uuid,
            "game_id"      => game.id,
            "server_id"    => server.id,
            "reference"    => "anything123456",
            "remote_ip"    => "1.1.1.1",
            "account_uuid" => nil,
            "created_at"   => "2024-09-02T12:00:01Z"
          }
        },
        returned
      )

      account = create_account
      server_vote2 = create_server_vote(
        game:,
        server:,
        reference: "anything123456",
        remote_ip: "1.1.1.1",
        account:,
        created_at: Time.iso8601("2024-09-02T12:00:01Z")
      )
      returned = described_class.new(server_vote2).call

      assert_equal(
        {
          "server_vote" => {
            "uuid"         => server_vote2.uuid,
            "game_id"      => game.id,
            "server_id"    => server.id,
            "reference"    => "anything123456",
            "remote_ip"    => "1.1.1.1",
            "account_uuid" => account.uuid,
            "created_at"   => "2024-09-02T12:00:01Z"
          }
        },
        returned
      )
    end
  end
end
