require 'rails_helper'

RSpec.describe Servers::ConsolidateRankingsSchedulerJob do
  describe '#perform' do
    context 'when method is current' do
      it 'enqueues ConsolidateRankingsJob for each game' do
        game1 = create(:game)
        game2 = create(:game)

        described_class.new.perform('current')

        expect(Servers::ConsolidateRankingsJob).to have_been_enqueued.with(game1, 'current')
        expect(Servers::ConsolidateRankingsJob).to have_been_enqueued.with(game2, 'current')
      end
    end

    context 'when method is all' do
      it 'enqueues ConsolidateRankingsJob for each game' do
        game1 = create(:game)
        game2 = create(:game)

        described_class.new.perform('all')

        expect(Servers::ConsolidateRankingsJob).to have_been_enqueued.with(game1, 'all')
        expect(Servers::ConsolidateRankingsJob).to have_been_enqueued.with(game2, 'all')
      end
    end

    context 'when method is unknown' do
      it 'raises an error' do
        expect do
          described_class.new.perform('something_else')
        end.to raise_error(/Invalid method for Servers::ConsolidateRankingsSchedulerJob/)
      end
    end
  end
end
