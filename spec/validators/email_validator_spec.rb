# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailValidator do
  describe '#validate' do
    context 'when record has an invalid email' do
      it 'sets record.errors' do
        record = generic_model_class.new(email: 'abcdef')

        validator = described_class.new(attributes: [:email])
        validator.validate(record)

        expect(record.errors.of_kind?(:email, :format_is_not_valid)).to be(true)
      end
    end

    context 'when record has an unsupported email' do
      it 'sets record.errors' do
        record = generic_model_class.new(email: 'user@example.com')

        validator = described_class.new(attributes: [:email])
        validator.validate(record)

        expect(record.errors.of_kind?(:email, :domain_is_not_supported)).to be(true)
      end
    end

    context 'when record has a blank email' do
      it 'does not set errors' do
        record = generic_model_class.new(email: ' ')

        validator = described_class.new(attributes: [:email])
        validator.validate(record)

        expect(record.errors.key?(:email)).to be(false)
      end
    end

    context 'when record has a valid email' do
      it 'does not set errors' do
        record = generic_model_class.new(email: 'user@upper.town')

        validator = described_class.new(attributes: [:email])
        validator.validate(record)

        expect(record.errors.key?(:email)).to be(false)
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
