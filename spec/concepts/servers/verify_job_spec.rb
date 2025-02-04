# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::VerifyJob do
  describe '#perform' do
    it 'calls Verify for server' do
      server = create(:server)
      servers_verify = instance_double(Servers::Verify)
      allow(Servers::Verify)
        .to receive(:new)
        .and_return(servers_verify)
      allow(servers_verify)
        .to receive(:call)

      described_class.new.perform(server)

      expect(Servers::Verify)
        .to have_received(:new)
        .with(server)
      expect(servers_verify)
        .to have_received(:call)
    end
  end
end
