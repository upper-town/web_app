# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ValidatePhoneNumber do
  it 'initializes with errors not empty before calling #valid?' do
    validator = described_class.new('+1 (202) 555-9999')

    expect(validator.errors).not_to be_empty
    expect(validator.errors).to include(:not_validated_yet)
  end

  describe '#valid?' do
    context 'when phone number is not valid' do
      it 'returns false and sets errors' do
        [
          nil,
          '',
          " \n  ",
          'aaa',
          '0',
          '000',
          '1',
          '111',
        ].each do |invaild_phone_number|
          validator = described_class.new(invaild_phone_number)

          expect(validator.valid?).to be(false)
          expect(validator.errors).not_to be_empty
          expect(validator.errors).to include(:not_valid)
        end
      end
    end

    context 'when phone number is valid' do
      it 'returns true and does not set errors' do
        [
          '202-555-9999',
          '(202) 555-9999',
          '(202)555-9999',
          '+1-202-555-9999',
          '+1 (202) 555-9999',
          '+1(202)555-9999',
          '+12025559999',

          '16-95555-9999',
          '(16) 95555-9999',
          '(16)95555-9999',
          '+55-16-95555-9999',
          '+55 (16) 95555-9999',
          '+55(16)95555-9999',
          '+5516955559999',
        ].each do |valid_phone_number|
          validator = described_class.new(valid_phone_number)

          expect(validator.valid?).to be(true)
          expect(validator.errors).to be_empty
        end
      end
    end
  end

  describe '#phone_number' do
    it 'returns the given phone number value string' do
      expect(described_class.new(nil).phone_number).to eq('')
      expect(described_class.new('').phone_number).to  eq('')

      expect(described_class.new('abcdef').phone_number).to eq('abcdef')
      expect(described_class.new('+1 (202) 555-9999').phone_number).to eq('+1 (202) 555-9999')
    end
  end
end
