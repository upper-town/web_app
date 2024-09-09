# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::DeleteMarkedForDeletionJob do
  describe '#perform' do
    it 'enqueues job to destroy servers marked_for_deletion' do
      server1 = create(:server, archived_at: Time.current, marked_for_deletion_at: Time.current)
      _server2 = create(:server, archived_at: Time.current, marked_for_deletion_at: nil)
      server3 = create(:server, archived_at: Time.current, marked_for_deletion_at: Time.current)
      _server4 = create(:server, archived_at: nil, marked_for_deletion_at: nil)

      described_class.new.perform

      expect(Servers::DestroyJob).to have_enqueued_sidekiq_job.exactly(2).times
      expect(Servers::DestroyJob).to have_enqueued_sidekiq_job(server1.id)
      expect(Servers::DestroyJob).to have_enqueued_sidekiq_job(server3.id)
    end
  end
end
