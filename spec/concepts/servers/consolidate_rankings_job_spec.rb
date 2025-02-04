# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::ConsolidateRankingsJob do
  describe '#perform' do
    context 'when method is current' do
      it 'calls process_current' do
        consolidate_rankings = instance_double(Servers::ConsolidateRankings)
        allow(Servers::ConsolidateRankings).to receive(:new).and_return(consolidate_rankings)
        allow(consolidate_rankings).to receive(:process_current)
        game = create(:game)

        described_class.new.perform(game, 'current')

        expect(Servers::ConsolidateRankings).to have_received(:new).with(game)
        expect(consolidate_rankings).to have_received(:process_current)
      end
    end

    context 'when method is all' do
      it 'calls process_all' do
        consolidate_rankings = instance_double(Servers::ConsolidateRankings)
        allow(Servers::ConsolidateRankings).to receive(:new).and_return(consolidate_rankings)
        allow(consolidate_rankings).to receive(:process_all)
        game = create(:game)

        described_class.new.perform(game, 'all')

        expect(Servers::ConsolidateRankings).to have_received(:new).with(game)
        expect(consolidate_rankings).to have_received(:process_all)
      end
    end

    context 'when method is unknown' do
      it 'raises an error' do
        expect do
          described_class.new.perform(create(:game).id, 'something_else')
        end.to raise_error(/Invalid method for Servers::ConsolidateRankingsJob/)
      end
    end
  end
end
