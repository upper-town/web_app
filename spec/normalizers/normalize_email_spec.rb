require 'rails_helper'

RSpec.describe NormalizeEmail do
  describe '#call' do
    it 'just removes white spaces and transforms to lower case' do
      [
        [ nil, nil ],
        [ "\n\t \n", '' ],

        [ 'user@example.com',      'user@example.com' ],
        [ '  USER@example .COM  ', 'user@example.com' ],
        [ ' 1! @# user @ example .COM.net...(ORG)  ', '1!@#user@example.com.net...(org)' ]
      ].each do |value, expected|
        returned = described_class.new(value).call

        expect(returned).to(eq(expected), "Failed for #{value.inspect}")
      end
    end
  end
end
