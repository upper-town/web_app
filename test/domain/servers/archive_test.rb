# frozen_string_literal: true

require "test_helper"

class Servers::ArchiveTest < ActiveSupport::TestCase
  let(:described_class) { Servers::Archive }

  describe "#call" do
    describe "when server is archived" do
      it "returns failure" do
        server = create_server(archived_at: Time.current)

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Server is already archived"))
      end
    end

    describe "when server is not archived" do
      it "archives server and returns success" do
        freeze_time do
          server = create_server(archived_at: nil)

          result = described_class.new(server).call

          assert(result.success?)
          assert_equal(Time.current, server.reload.archived_at)
        end
      end
    end
  end
end
