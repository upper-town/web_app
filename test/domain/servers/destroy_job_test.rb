# frozen_string_literal: true

require "test_helper"

class Servers::DestroyJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::DestroyJob }

  describe "#perform" do
    it "deletes all ServerStat and ServerVote records, and deletes Server" do
      server = create_server
      create_server_stat(server:)
      create_server_vote(server:)

      assert_difference(-> { ServerStat.count }, -1) do
        assert_difference(-> { ServerVote.count }, -1) do
          assert_difference(-> { Server.count }, -1) do
            described_class.new.perform(server)
          end
        end
      end

      assert(ServerStat.where(server:).blank?)
      assert(ServerVote.where(server:).blank?)
      assert(Server.where(id: server.id).blank?)
    end
  end
end
