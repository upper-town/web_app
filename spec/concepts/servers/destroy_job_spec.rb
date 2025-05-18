require 'rails_helper'

RSpec.describe Servers::DestroyJob do
  describe '#perform' do
    it 'deletes all ServerStat and ServerVote records, and deletes Server' do
      server = create(:server)
      create(:server_stat, server: server)
      create(:server_vote, server: server)

      expect do
        described_class.new.perform(server)
      end.to(
        change(ServerStat, :count).by(-1).and(
          change(ServerVote, :count).by(-1).and(
            change(Server, :count).by(-1)
          )
        )
      )

      expect(ServerStat.where(server: server)).to be_blank
      expect(ServerVote.where(server: server)).to be_blank
      expect(Server.where(id: server.id)).to be_blank
    end
  end
end
