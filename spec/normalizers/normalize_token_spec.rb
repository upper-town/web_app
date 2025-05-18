require 'rails_helper'

RSpec.describe NormalizeToken do
  describe '#call' do
    it 'just removes white spaces' do
      [
        [ nil, nil ],
        [ "\n\t \n", '' ],

        [ "\n\t Aaaa1234 B  bbb 5678\n", 'Aaaa1234Bbbb5678' ]
      ].each do |value, expected|
        returned = described_class.new(value).call

        expect(returned).to(eq(expected), "Failed for #{value.inspect}")
      end
    end
  end
end
