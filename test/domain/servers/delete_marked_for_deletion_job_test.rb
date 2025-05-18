# frozen_string_literal: true

require "test_helper"

class Servers::DeleteMarkedForDeletionJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::DeleteMarkedForDeletionJob }

  describe "#perform" do
    it "enqueues job to destroy servers marked_for_deletion" do
      server1 = create_server(archived_at: Time.current, marked_for_deletion_at: Time.current)
      _server2 = create_server(archived_at: Time.current, marked_for_deletion_at: nil)
      server3 = create_server(archived_at: Time.current, marked_for_deletion_at: Time.current)
      _server4 = create_server(archived_at: nil, marked_for_deletion_at: nil)

      described_class.new.perform

      assert_equal(2, enqueued_jobs.count { it[:job] == Servers::DestroyJob })
      assert_enqueued_with(job: Servers::DestroyJob, args: [server1])
      assert_enqueued_with(job: Servers::DestroyJob, args: [server3])
    end
  end
end
