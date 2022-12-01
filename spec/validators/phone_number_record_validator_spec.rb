# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhoneNumberRecordValidator do
  describe '#validate' do
    context 'when record has an invalid phone number' do
      it 'set record.errors' do
        [
          'aaa',
          '0',
          '000',
          '1',
          '111',
        ].each do |invalid_phone_number|
          record = generic_active_record_class.new(phone_number: invalid_phone_number)

          validator = described_class.new(record)
          validator.validate

          expect(record.errors).not_to be_empty
          expect(record.errors.messages[:phone_number]).to include('not valid')
        end
      end
    end

    context 'when record has a valid phone number' do
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
          record = generic_active_record_class.new(phone_number: valid_phone_number)

          validator = described_class.new(record)
          validator.validate

          expect(record.errors).to be_empty
        end
      end
    end

    describe 'passing :attribute_name options' do
      it 'uses the attribute_name from options instead of :phone_number' do
        record = generic_active_record_class.new(other: 'invalid_phone_number')

        validator = described_class.new(record, attribute_name: :other)
        validator.validate

        expect(record.errors).not_to be_empty
        expect(record.errors.messages[:other]).to include('not valid')
      end
    end
  end

  def generic_active_record_class
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Attributes

      attribute :phone_number
      attribute :other
    end
  end
end
