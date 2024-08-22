# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NormalizeToken do
  describe '#call' do
    it 'just removes white spaces' do
      [
        [nil, nil],
        ["\n\t \n", ''],

        ["\n\t Aaaa1234 B  bbb 5678\n", 'Aaaa1234Bbbb5678'],
      ].each do |given, expected|
        expect(described_class.new(given).call).to eq(expected)
      end
    end
  end
end
