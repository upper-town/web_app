# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::Unarchive do
  describe '#call' do
    context 'when server is marked_for_deletion' do
      it 'returns failure' do
        server = create(:server, marked_for_deletion_at: Time.current)

        result = described_class.new(server).call

        expect(result.failure?).to be(true)
        expect(result.errors.of_kind?(:base, 'Server is marked for deletion. Unmark it first and then you can unarchive it')).to be(true)
      end
    end

    context 'when server is not archived' do
      it 'returns failure' do
        server = create(:server, archived_at: nil)

        result = described_class.new(server).call

        expect(result.failure?).to be(true)
        expect(result.errors.of_kind?(:base, 'Server is not archived already')).to be(true)
      end
    end

    context 'when server is archived' do
      it 'returns success and updates archived_at to nil' do
        server = create(:server, archived_at: Time.current)

        result = described_class.new(server).call

        expect(result.success?).to be(true)
        expect(server.archived_at).to be_nil
      end
    end
  end
end
