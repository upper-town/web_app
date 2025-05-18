# frozen_string_literal: true

require "test_helper"

class Servers::UnarchiveTest < ActiveSupport::TestCase
  let(:described_class) { Servers::Unarchive }

  describe "#call" do
    describe "when server is marked_for_deletion" do
      it "returns failure" do
        server = create_server(marked_for_deletion_at: Time.current)

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Server is marked for deletion. Unmark it first and then you can unarchive it"))
      end
    end

    describe "when server is not archived" do
      it "returns failure" do
        server = create_server(archived_at: nil)

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Server is not archived already"))
      end
    end

    describe "when server is archived" do
      it "returns success and updates archived_at to nil" do
        server = create_server(archived_at: Time.current)

        result = described_class.new(server).call

        assert(result.success?)
        assert_nil(server.archived_at)
      end
    end
  end
end
