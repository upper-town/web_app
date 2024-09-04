# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ServersQuery do
  describe '#call' do
    it 'returns all servers ordered by id desc' do
      server1 = create(:server)
      server2 = create(:server)
      server3 = create(:server)

      expect(described_class.new.call).to eq([
        server3,
        server2,
        server1,
      ])
    end
  end
end
