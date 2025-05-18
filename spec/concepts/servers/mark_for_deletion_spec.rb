require 'rails_helper'

RSpec.describe Servers::MarkForDeletion do
  describe '#call' do
    context 'when server is not archived' do
      it 'returns failure' do
        server = create(:server, archived_at: nil)

        result = described_class.new(server).call

        expect(result.failure?).to be(true)
        expect(result.errors.of_kind?(:base, 'Server must be archived and then it can be marked/unmarked for deletion')).to be(true)
      end
    end

    context 'when server is already marked_for_deletion' do
      it 'returns failure' do
        server = create(:server, archived_at: Time.current, marked_for_deletion_at: Time.current)

        result = described_class.new(server).call

        expect(result.failure?).to be(true)
        expect(result.errors.of_kind?(:base, 'Server is already marked for deletion')).to be(true)
      end
    end

    context 'when server is archived and not marked_for_deletion' do
      it 'returns success and updates marked_for_deletion_at' do
        server = create(:server, archived_at: Time.current, marked_for_deletion_at: nil)

        freeze_time do
          result = described_class.new(server).call

          expect(result.success?).to be(true)
          expect(server.marked_for_deletion_at).to eq(Time.current)
        end
      end
    end
  end
end
