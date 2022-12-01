# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhoneNumberNormalizer do
  describe '#call' do
    it 'tries to normalize phone number to international format' do
      [
        [nil, ''],
        ['', ''],

        ['202-555-9999',      '+12025559999'],
        ['(202) 555-9999',    '+12025559999'],
        ['(202)555-9999',     '+12025559999'],
        ['+1-202-555-9999',   '+12025559999'],
        ['+1 (202) 555-9999', '+12025559999'],
        ['+1(202)555-9999',   '+12025559999'],
        ['+12025559999',      '+12025559999'],

        ['16-95555-9999',       '+5516955559999'],
        ['(16) 95555-9999',     '+5516955559999'],
        ['(16)95555-9999',      '+5516955559999'],
        ['+55-16-95555-9999',   '+5516955559999'],
        ['+55 (16) 95555-9999', '+5516955559999'],
        ['+55(16)95555-9999',   '+5516955559999'],
        ['+5516955559999',      '+5516955559999'],
      ].each do |given_phone_number, expected_phone_number|
        expect(described_class.new(given_phone_number).call).to eq(expected_phone_number)
      end
    end
  end
end
