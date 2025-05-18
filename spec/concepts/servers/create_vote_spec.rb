require 'rails_helper'

RSpec.describe Servers::CreateVote do
  describe '#call' do
    context 'when person has voted for this game recently' do
      it 'returns failure' do
        server = create(:server)
        server_vote = build(:server_vote)
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        account = create(:account)
        rate_limiter_key = "servers_create_vote:#{server.game_id}:1.1.1.1"
        Rails.cache.write(rate_limiter_key, 1)

        result = nil
        expect do
          result = described_class.new(server, server_vote, request, account).call
        end.not_to change(ServerVote, :count)

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/You have already voted for this game\. Please try again .+/)

        expect(Rails.cache.read(rate_limiter_key)).to eq(2)

        expect(Servers::ConsolidateVoteCountsJob).not_to have_been_enqueued
        expect(ServerWebhooks::CreateEvents::ServerVoteCreatedJob).not_to have_been_enqueued
      end
    end

    context 'when server_vote is invalid for some reason' do
      it 'returns failure and uncalls rate_limiter' do
        server = create(:server, archived_at: Time.current)
        server_vote = build(:server_vote)
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        account = create(:account)
        rate_limiter_key = "servers_create_vote:#{server.game_id}:1.1.1.1"

        result = nil
        expect do
          result = described_class.new(server, server_vote, request, account).call
        end.not_to change(ServerVote, :count)

        expect(result.failure?).to be(true)
        expect(result.errors[:server]).to include(/cannot be archived/)

        expect(Rails.cache.read(rate_limiter_key)).to eq(0)

        expect(Servers::ConsolidateVoteCountsJob).not_to have_been_enqueued
        expect(ServerWebhooks::CreateEvents::ServerVoteCreatedJob).not_to have_been_enqueued
      end
    end

    context 'when an error is raised' do
      it 'raises error and uncalls rate_limiter' do
        server = create(:server)
        server_vote = build(:server_vote)
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        account = create(:account)
        rate_limiter_key = "servers_create_vote:#{server.game_id}:1.1.1.1"
        allow(server_vote).to receive(:save!).and_raise(ActiveRecord::ActiveRecordError)

        expect do
          described_class.new(server, server_vote, request, account).call
        end.to(
          raise_error(ActiveRecord::ActiveRecordError).and(
            change(ServerVote, :count).by(0)
          )
        )
        expect(server_vote).to have_received(:save!)

        expect(Rails.cache.read(rate_limiter_key)).to eq(0)

        expect(Servers::ConsolidateVoteCountsJob).not_to have_been_enqueued
        expect(ServerWebhooks::CreateEvents::ServerVoteCreatedJob).not_to have_been_enqueued
      end
    end

    context 'when everything is correct' do
      it 'returns success, creates server_vote and enqueues jobs' do
        server = create(:server)
        server_vote = build(:server_vote, reference: 'anything123456')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        account = create(:account)
        rate_limiter_key = "servers_create_vote:#{server.game_id}:1.1.1.1"

        result = nil
        expect do
          result = described_class.new(server, server_vote, request, account).call
        end.to change(ServerVote, :count).by(1)

        expect(result.success?).to be(true)
        expect(result.data[:server_vote]).to eq(ServerVote.last)
        expect(result.data[:server_vote].server).to eq(server)
        expect(result.data[:server_vote].game).to eq(server.game)
        expect(result.data[:server_vote].country_code).to eq(server.country_code)
        expect(result.data[:server_vote].remote_ip).to eq('1.1.1.1')
        expect(result.data[:server_vote].reference).to eq('anything123456')
        expect(result.data[:server_vote].account).to eq(account)

        expect(Rails.cache.read(rate_limiter_key)).to eq(1)

        expect(Servers::ConsolidateVoteCountsJob)
          .to have_been_enqueued
          .with(server, 'current')
          .on_queue('critical')
        expect(ServerWebhooks::CreateEvents::ServerVoteCreatedJob)
          .to have_been_enqueued
          .with(result.data[:server_vote])
      end
    end
  end
end
