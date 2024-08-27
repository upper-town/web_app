# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::VerifySchedulerJob do
  describe '#perform' do
    it 'performs VerifyJob async for each not_archived server' do
      server1 = create(:server, archived_at: nil)
      _server2 = create(:server, archived_at: Time.current)
      server3 = create(:server, archived_at: nil)

      described_class.new.perform

      expect(Servers::VerifyJob).to have_enqueued_sidekiq_job.exactly(2).times
      expect(Servers::VerifyJob).to have_enqueued_sidekiq_job(server1.id)
      expect(Servers::VerifyJob).to have_enqueued_sidekiq_job(server3.id)
    end
  end
end
