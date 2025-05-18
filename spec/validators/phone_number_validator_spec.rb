require 'rails_helper'

RSpec.describe PhoneNumberValidator do
  describe '#validate' do
    context 'when record has an invalid phone number' do
      it 'sets record.errors' do
        record = generic_model_class.new(phone_number: 'abcdef')

        validator = described_class.new(attributes: [ :phone_number ])
        validator.validate(record)

        expect(record.errors.of_kind?(:phone_number, :not_valid)).to be(true)
      end
    end

    context 'when record has a blank phone number' do
      it 'does not set errors' do
        record = generic_model_class.new(phone_number: ' ')

        validator = described_class.new(attributes: [ :phone_number ])
        validator.validate(record)

        expect(record.errors.key?(:phone_number)).to be(false)
      end
    end

    context 'when record has a possible phone number' do
      it 'does not set errors' do
        record = generic_model_class.new(phone_number: '+1 (202) 555-9999')

        validator = described_class.new(attributes: [ :phone_number ])
        validator.validate(record)

        expect(record.errors.key?(:phone_number)).to be(false)
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
