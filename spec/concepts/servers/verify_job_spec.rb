# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::VerifyJob do
  describe '#perform' do
    context 'when server is not found' do
      it 'raises an error' do
        expect do
          described_class.new.perform(0)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when server is found' do
      it 'calls Verify for server' do
        server = create(:server)
        servers_verify = instance_double(Servers::Verify)
        allow(Servers::Verify)
          .to receive(:new)
          .and_return(servers_verify)
        allow(servers_verify)
          .to receive(:call)

        described_class.new.perform(server.id)

        expect(Servers::Verify)
          .to have_received(:new)
          .with(server)
        expect(servers_verify)
          .to have_received(:call)
      end
    end
  end
end
