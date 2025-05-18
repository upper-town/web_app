# frozen_string_literal: true

require "test_helper"

class Servers::DeleteArchivedWithoutVotesJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::DeleteArchivedWithoutVotesJob }

  describe "#perform" do
    it "enqueues job to destroy archived servers without votes" do
      server1 = create_server(archived_at: nil)
      server2 = create_server(archived_at: nil)
      server3 = create_server(archived_at: nil)
      server4 = create_server(archived_at: nil)
      create_server_vote(server: server2)
      create_server_vote(server: server4)
      server1.update!(archived_at: Time.current)
      server3.update!(archived_at: Time.current)

      described_class.new.perform

      assert_equal(2, enqueued_jobs.count { it[:job] == Servers::DestroyJob })
      assert_enqueued_with(job: Servers::DestroyJob, args: [server1])
      assert_enqueued_with(job: Servers::DestroyJob, args: [server3])
    end
  end
end
