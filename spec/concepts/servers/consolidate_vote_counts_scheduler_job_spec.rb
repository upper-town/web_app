# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::ConsolidateVoteCountsSchedulerJob do
  describe '#perform' do
    context 'when method is current' do
      it 'enqueues ConsolidateVoteCountsJob for each server' do
        server1 = create(:server)
        server2 = create(:server)

        described_class.new.perform('current')

        expect(Servers::ConsolidateVoteCountsJob).to have_enqueued_sidekiq_job(server1.id, 'current')
        expect(Servers::ConsolidateVoteCountsJob).to have_enqueued_sidekiq_job(server2.id, 'current')
      end
    end

    context 'when method is all' do
      it 'enqueues ConsolidateVoteCountsJob for each server' do
        server1 = create(:server)
        server2 = create(:server)

        described_class.new.perform('all')

        expect(Servers::ConsolidateVoteCountsJob).to have_enqueued_sidekiq_job(server1.id, 'all')
        expect(Servers::ConsolidateVoteCountsJob).to have_enqueued_sidekiq_job(server2.id, 'all')
      end
    end

    context 'when method is unknown' do
      it 'raises an error' do
        expect do
          described_class.new.perform('something_else')
        end.to raise_error(/Invalid method for Servers::ConsolidateVoteCountsSchedulerJob/)
      end
    end
  end
end
