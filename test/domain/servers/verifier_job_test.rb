# frozen_string_literal: true

require "test_helper"

class Servers::VerifierJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::VerifierJob }

  describe "#perform" do
    it "performs VerifyJob async for each not_archived server" do
      server1 = create_server(archived_at: nil)
      _server2 = create_server(archived_at: Time.current)
      server3 = create_server(archived_at: nil)

      described_class.new.perform

      assert_equal(2, enqueued_jobs.count { it[:job] == Servers::VerifyJob })
      assert_enqueued_with(job: Servers::VerifyJob, args: [server1])
      assert_enqueued_with(job: Servers::VerifyJob, args: [server3])
    end
  end
end
