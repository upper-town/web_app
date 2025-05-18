# frozen_string_literal: true

require "test_helper"

class Servers::UnmarkForDeletionTest < ActiveSupport::TestCase
  let(:described_class) { Servers::UnmarkForDeletion }

  describe "#call" do
    describe "when server is not archived" do
      it "returns failure" do
        server = create_server(archived_at: nil)

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Server must be archived and then it can be marked/unmarked for deletion"))
      end
    end

    describe "when server is already not marked_for_deletion" do
      it "returns failure" do
        server = create_server(archived_at: Time.current, marked_for_deletion_at: nil)

        result = described_class.new(server).call

        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Server is already not marked for deletion"))
      end
    end

    describe "when server is archived and marked_for_deletion" do
      it "returns success and updates marked_for_deletion_at to nil" do
        server = create_server(archived_at: Time.current, marked_for_deletion_at: Time.current)

        result = described_class.new(server).call

        assert(result.success?)
        assert_nil(server.marked_for_deletion_at)
      end
    end
  end
end
