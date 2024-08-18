# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhoneNumberRecordValidator do
  describe '#validate' do
    context 'when record has an invalid phone number' do
      it 'sets record.errors' do
        [
          'aaa',
          '0',
          '000',
          '1',
          '111',
        ].each do |invalid_phone_number|
          record = generic_model_class.new(phone_number: invalid_phone_number)

          validator = described_class.new(record)
          validator.validate

          expect(record.errors).not_to be_empty
          expect(record.errors.of_kind?(:phone_number, :not_valid)).to be(true)
        end
      end
    end

    context 'when record has a valid phone number or blank' do
      it 'does not set errors' do
        [
          nil,
          '',
          " \n  ",

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
          record = generic_model_class.new(phone_number: valid_phone_number)

          validator = described_class.new(record)
          validator.validate

          expect(record.errors).to be_empty
        end
      end
    end

    describe 'passing :attribute_name options' do
      it 'uses the attribute_name from options instead of :phone_number' do
        record = generic_model_class.new(other: 'abcdef')

        validator = described_class.new(record, attribute_name: :other)
        validator.validate

        expect(record.errors).not_to be_empty
        expect(record.errors.of_kind?(:other, :not_valid)).to be(true)
      end
    end
  end

  def generic_model_class
    Class.new(ApplicationModel) do
      attribute :phone_number
      attribute :other
    end
  end
end
