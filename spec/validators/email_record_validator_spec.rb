# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailRecordValidator do
  describe '#validate' do
    context 'when record has an invalid email' do
      it 'set record.errors' do
        record = generic_active_record_class.new(email: 'invalid_email')

        validator = described_class.new(record)
        validator.validate

        expect(record.errors).not_to be_empty
        expect(record.errors.messages[:email]).to be_present
      end
    end

    context 'when record has a valid email' do
      it 'does not set errors' do
        record = generic_active_record_class.new(email: 'user@google.com')

        validator = described_class.new(record)
        validator.validate

        expect(record.errors).to be_empty
      end
    end

    describe 'passing :attribute_name options' do
      it 'uses the attribute_name from options instead of :email' do
        record = generic_active_record_class.new(other: 'invalid_email')

        validator = described_class.new(record, attribute_name: :other)
        validator.validate

        expect(record.errors).not_to be_empty
        expect(record.errors.messages[:other]).to be_present
      end
    end
  end

  def generic_active_record_class
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Attributes

      attribute :email
      attribute :other
    end
  end
end
