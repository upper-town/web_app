# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhoneNumberValidator do
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

          validator = described_class.new(attributes: [:phone_number])
          validator.validate(record)

          expect(record.errors.of_kind?(:phone_number, :not_valid)).to be(true)
        end
      end
    end

    context 'when record has a blank phone number' do
      it 'does not set errors' do
        [
          nil,
          '',
          " \n  ",
        ].each do |blank_phone_number|
          record = generic_model_class.new(phone_number: blank_phone_number)

          validator = described_class.new(attributes: [:phone_number])
          validator.validate(record)

          expect(record.errors).to be_empty
        end
      end
    end

    context 'when record has a possible phone number' do
      it 'does not set errors' do
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
        ].each do |possible_phone_number|
          record = generic_model_class.new(phone_number: possible_phone_number)

          validator = described_class.new(attributes: [:phone_number])
          validator.validate(record)

          expect(record.errors).to be_empty
        end
      end
    end
  end

  def generic_model_class
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.name
        'GenericModelClass'
      end

      attribute :phone_number
      attribute :other
    end
  end
end
