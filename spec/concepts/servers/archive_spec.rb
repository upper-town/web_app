# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::Archive do
  describe '#call' do
    context 'when server is archived' do
      it 'returns failure' do
        server = create(:server, archived_at: Time.current)

        result = described_class.new(server).call

        expect(result.failure?).to be(true)
        expect(result.errors.of_kind?(:base, 'Server is already archived')).to be(true)
      end
    end

    context 'when server is not archived' do
      it 'archives server and returns success' do
        freeze_time do
          server = create(:server, archived_at: nil)

          result = described_class.new(server).call

          expect(result.success?).to be(true)
          expect(server.reload.archived_at).to eq(Time.current)
        end
      end
    end
  end
end
