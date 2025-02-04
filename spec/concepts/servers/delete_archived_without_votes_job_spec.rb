# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::DeleteArchivedWithoutVotesJob do
  describe '#perform' do
    it 'enqueues job to destroy archived servers without votes' do
      server1 = create(:server, archived_at: nil)
      server2 = create(:server, archived_at: nil)
      server3 = create(:server, archived_at: nil)
      server4 = create(:server, archived_at: nil)
      create(:server_vote, server: server2)
      create(:server_vote, server: server4)
      server1.update!(archived_at: Time.current)
      server3.update!(archived_at: Time.current)

      described_class.new.perform

      expect(Servers::DestroyJob).to have_been_enqueued.exactly(2).times
      expect(Servers::DestroyJob).to have_been_enqueued.with(server1)
      expect(Servers::DestroyJob).to have_been_enqueued.with(server3)
    end
  end
end
