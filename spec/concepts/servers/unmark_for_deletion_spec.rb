# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::UnmarkForDeletion do
  describe '#call' do
    context 'when server is not archived' do
      it 'returns failure' do
        server = create(:server, archived_at: nil)

        result = described_class.new(server).call

        expect(result.failure?).to be(true)
        expect(result.errors.of_kind?(:base, 'Server must be archived and then it can be marked/unmarked for deletion')).to be(true)
      end
    end

    context 'when server is already not marked_for_deletion' do
      it 'returns failure' do
        server = create(:server, archived_at: Time.current, marked_for_deletion_at: nil)

        result = described_class.new(server).call

        expect(result.failure?).to be(true)
        expect(result.errors.of_kind?(:base, 'Server is already not marked for deletion')).to be(true)
      end
    end

    context 'when server is archived and marked_for_deletion' do
      it 'returns success and updates marked_for_deletion_at to nil' do
        server = create(:server, archived_at: Time.current, marked_for_deletion_at: Time.current)

        result = described_class.new(server).call

        expect(result.success?).to be(true)
        expect(server.marked_for_deletion_at).to be_nil
      end
    end
  end
end
