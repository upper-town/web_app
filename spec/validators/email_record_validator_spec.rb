# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailRecordValidator do
  describe '#validate' do
    context 'when record has an invalid email' do
      it 'sets record.errors' do
        record = generic_model_class.new(email: 'abcdef')

        validator = described_class.new(record)
        validator.validate

        expect(record.errors).not_to be_empty
        expect(record.errors.of_kind?(:email, :format_is_not_valid)).to be(true)
      end
    end

    context 'when record has an unsupported email' do
      it 'sets record.errors' do
        record = generic_model_class.new(email: 'user@example.com')

        validator = described_class.new(record)
        validator.validate

        expect(record.errors).not_to be_empty
        expect(record.errors.of_kind?(:email, :domain_is_not_supported)).to be(true)
      end
    end

    context 'when record has a valid email' do
      it 'does not set errors' do
        record = generic_model_class.new(email: 'user@google.com')

        validator = described_class.new(record)
        validator.validate

        expect(record.errors).to be_empty
      end
    end

    describe 'passing :attribute_name options' do
      it 'uses the attribute_name from options instead of :email' do
        record = generic_model_class.new(other: 'abcdef')

        validator = described_class.new(record, attribute_name: :other)
        validator.validate

        expect(record.errors).not_to be_empty
        expect(record.errors.of_kind?(:other, :format_is_not_valid)).to be(true)
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

      attribute :email
      attribute :other
    end
  end
end
