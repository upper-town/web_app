require 'rails_helper'

RSpec.describe Servers::VerifySchedulerJob do
  describe '#perform' do
    it 'performs VerifyJob async for each not_archived server' do
      server1 = create(:server, archived_at: nil)
      _server2 = create(:server, archived_at: Time.current)
      server3 = create(:server, archived_at: nil)

      described_class.new.perform

      expect(Servers::VerifyJob).to have_been_enqueued.exactly(2).times
      expect(Servers::VerifyJob).to have_been_enqueued.with(server1)
      expect(Servers::VerifyJob).to have_been_enqueued.with(server3)
    end
  end
end
