require 'rails_helper'

RSpec.describe Servers::ConsolidateVoteCountsJob do
  describe '#perform' do
    context 'when method is current' do
      it 'calls process_current' do
        consolidate_vote_counts = instance_double(Servers::ConsolidateVoteCounts)
        allow(Servers::ConsolidateVoteCounts).to receive(:new).and_return(consolidate_vote_counts)
        allow(consolidate_vote_counts).to receive(:process_current)
        server = create(:server)

        described_class.new.perform(server, 'current')

        expect(Servers::ConsolidateVoteCounts).to have_received(:new).with(server)
        expect(consolidate_vote_counts).to have_received(:process_current)
      end
    end

    context 'when method is all' do
      it 'calls process_all' do
        consolidate_vote_counts = instance_double(Servers::ConsolidateVoteCounts)
        allow(Servers::ConsolidateVoteCounts).to receive(:new).and_return(consolidate_vote_counts)
        allow(consolidate_vote_counts).to receive(:process_all)
        server = create(:server)

        described_class.new.perform(server, 'all')

        expect(Servers::ConsolidateVoteCounts).to have_received(:new).with(server)
        expect(consolidate_vote_counts).to have_received(:process_all)
      end
    end

    context 'when method is unknown' do
      it 'raises an error' do
        expect do
          described_class.new.perform(create(:server).id, 'something_else')
        end.to raise_error(/Invalid method for Servers::ConsolidateVoteCountsJob/)
      end
    end
  end
end
