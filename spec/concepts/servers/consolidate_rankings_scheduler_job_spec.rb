# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::ConsolidateRankingsSchedulerJob do
  describe '#perform' do
    context 'when method is current' do
      it 'enqueues ConsolidateRankingsJob for each game' do
        game1 = create(:game)
        game2 = create(:game)

        described_class.new.perform('current')

        expect(Servers::ConsolidateRankingsJob).to have_enqueued_sidekiq_job(game1.id, 'current')
        expect(Servers::ConsolidateRankingsJob).to have_enqueued_sidekiq_job(game2.id, 'current')
      end
    end

    context 'when method is all' do
      it 'enqueues ConsolidateRankingsJob for each game' do
        game1 = create(:game)
        game2 = create(:game)

        described_class.new.perform('all')

        expect(Servers::ConsolidateRankingsJob).to have_enqueued_sidekiq_job(game1.id, 'all')
        expect(Servers::ConsolidateRankingsJob).to have_enqueued_sidekiq_job(game2.id, 'all')
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
