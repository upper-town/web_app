# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Result do
  describe '#initialize' do
    it 'has default values for errors and attributes' do
      result = described_class.new

      expect(result.errors).to be_empty
      expect(result.errors).to be_a(ActiveModel::Errors)

      expect(result.attributes).to be_empty
      expect(result.attributes).to be_a(Hash)
      expect(result.attributes.object_id).to eq(result.data.object_id)
    end

    describe 'setting errors' do
      it 'sets errors from Hash with String or Array values, and skips blanks' do
        result = described_class.new(
          {
            error_code_1: 'error message 1',
            error_code_2: ' ',
            error_code_3: false,
            error_code_4: nil,
            error_code_5: [],
            error_code_6: ['error message 1', ' ', false, nil, 'error message 2']
          }
        )

        expect(result.errors).not_to be_empty
        expect(result.errors.messages).to include(
          { error_code_1: ['error message 1'] },
          { error_code_6: ['error message 1', 'error message 2'] },
        )
        expect(result.errors.messages).not_to include(
          :error_code_2,
          :error_code_3,
          :error_code_4,
          :error_code_5,
        )
      end

      it 'sets errors from Array, and skips blanks' do
        result = described_class.new(
          ['error message 1', ' ', false, nil, 'error message 2']
        )

        expect(result.errors).not_to be_empty
        expect(result.errors.messages).to eq(
          { base: ['error message 1', 'error message 2'] },
        )
      end

      it 'sets errors from String, Symbol, Numeric, and skips blanks' do
        [
          ['error message 1', { base: ['error message 1'] }],
          [:error_message_1,  { base: ['error_message_1'] }],
          [12345,             { base: ['12345']  }],
          [123.45,            { base: ['123.45'] }],
        ].each do |error_value, expected_error_messages|
          result = described_class.new(error_value)

          expect(result.errors).not_to be_empty
          expect(result.errors.messages).to eq(expected_error_messages)
        end

        [' ', '', :'', nil].each do |blank_error_value|
          result = described_class.new(blank_error_value)

          expect(result.errors).to be_empty
        end
      end

      it 'sets errors from ActiveModel::Errors' do
        active_model_errors = ActiveModel::Errors.new(nil)
        active_model_errors.add(:error_code, 'some error message')

        result = described_class.new(active_model_errors)

        expect(result.errors).not_to be_empty
        expect(result.errors.messages).to eq(
          { error_code: ['some error message'] }
        )
      end

      it 'sets errors from true with a generic message' do
        result = described_class.new(true)

        expect(result.errors).not_to be_empty
        expect(result.errors.messages).to eq({ base: ['An error has occurred'] })
      end

      it 'does not set errors from nil, false' do
        [nil, false].each do |nil_or_false_error_value|
          result = described_class.new(nil_or_false_error_value)

          expect(result.errors).to be_empty
        end
      end

      it 'raises an exception when errors class is invalid' do
        expect { described_class.new(Time.current) }
          .to raise_exception(/Could not build_active_model_errors for Result: invalid error_values.class/)
      end
    end

    describe 'setting attributes' do
      it 'uses with_indifferent_access' do
        result = described_class.new(
          nil,
          {
            some_attr: 'some value',
            'another attr' => 'another value',
            42 => 'forty two'
          }
        )

        expect(result.attributes['some_attr']).to eq('some value')
        expect(result.attributes[:'another attr']).to eq('another value')
        expect(result.attributes[42]).to eq('forty two')

        expect(result.attributes).to eq(
          {
            'some_attr' => 'some value',
            'another attr' => 'another value',
            42 => 'forty two'
          }
        )
      end
    end
  end

  describe '#success?' do
    it 'returns true when #errors is empty' do
      result = described_class.new(nil)

      expect(result.errors).to be_empty
      expect(result.success?).to eq(true)
    end

    it 'returns false when #errors is not empty' do
      result = described_class.new('some error message')

      expect(result.errors).not_to be_empty
      expect(result.success?).to eq(false)
    end
  end

  describe '#failure?' do
    it 'returns true when #errors is not empty' do
      result = described_class.new('some error message')

      expect(result.errors).not_to be_empty
      expect(result.failure?).to eq(true)
    end

    it 'returns false when #errors is empty' do
      result = described_class.new(nil)

      expect(result.errors).to be_empty
      expect(result.failure?).to eq(false)
    end
  end

  describe '#add_errors' do
    it 'adds to errors from Hash with String or Array values, and skips blanks' do
      result = described_class.new('some existing error message')

      result.add_errors(
        {
          error_code_1: 'error message 1',
          error_code_2: ' ',
          error_code_3: false,
          error_code_4: nil,
          error_code_5: [],
          error_code_6: ['error message 1', ' ', false, nil, 'error message 2']
        }
      )

      expect(result.errors).not_to be_empty
      expect(result.errors.messages).to include(
        { base: ['some existing error message'] },
        { error_code_1: ['error message 1'] },
        { error_code_6: ['error message 1', 'error message 2'] },
      )
      expect(result.errors.messages).not_to include(
        :error_code_2,
        :error_code_3,
        :error_code_4,
        :error_code_5,
      )
    end

    it 'adds to errors from Array, and skips blanks' do
      result = described_class.new('some existing error message')

      result.add_errors(
        ['error message 1', ' ', false, nil, 'error message 2']
      )

      expect(result.errors).not_to be_empty
      expect(result.errors.messages).to eq(
        { base: ['some existing error message', 'error message 1', 'error message 2'] },
      )
    end

    it 'adds to errors from String, Symbol, Numeric, and skips blanks' do
      [
        ['error message 1', { base: ['some existing error message', 'error message 1'] }],
        [:error_message_1,  { base: ['some existing error message', 'error_message_1'] }],
        [12345,             { base: ['some existing error message', '12345']  }],
        [123.45,            { base: ['some existing error message', '123.45'] }],
      ].each do |error_value, expected_error_messages|
        result = described_class.new('some existing error message')

        result.add_errors(error_value)

        expect(result.errors).not_to be_empty
        expect(result.errors.messages).to eq(
          expected_error_messages
        )
      end

      [' ', '', :'', nil].each do |blank_error_value|
        result = described_class.new('some existing error message')

        result.add_errors(blank_error_value)

        expect(result.errors).not_to be_empty
        expect(result.errors.messages).to eq(
          { base: ['some existing error message'] }
        )
      end
    end

    it 'adds to errors from ActiveModel::Errors' do
      active_model_errors = ActiveModel::Errors.new(nil)
      active_model_errors.add(:error_code, 'some error message')

      result = described_class.new('some existing error message')

      result.add_errors(active_model_errors)

      expect(result.errors).not_to be_empty
      expect(result.errors.messages).to eq(
        {
          base: ['some existing error message'],
          error_code: ['some error message']
        }
      )
    end

    it 'adds to errors from true with a generic message' do
      result = described_class.new('some existing error message')

      result.add_errors(true)

      expect(result.errors).not_to be_empty
      expect(result.errors.messages).to eq(
        { base: ['some existing error message', 'An error has occurred'] }
      )
    end

    it 'does not add to errors from nil, false' do
      [nil, false].each do |nil_or_false_error_value|
        result = described_class.new('some existing error message')

        result.add_errors(nil_or_false_error_value)

        expect(result.errors).not_to be_empty
        expect(result.errors.messages).to eq(
          { base: ['some existing error message'] }
        )
      end
    end

    it 'raises an error when errors class is invalid' do
      expect do
        result = described_class.new('some existing error message')

        result.add_errors(Time.current)
      end.to raise_error(/Could not build_active_model_errors for Result: invalid error_values.class/)
    end
  end

  describe '.success' do
    it 'creates an instance with empty errors and empty attributes' do
      result = described_class.success

      expect(result.errors).to be_empty
      expect(result.attributes).to be_empty
    end

    it 'accepts attributes only' do
      result = described_class.success(some_attr: 'some value')

      expect(result.errors).to be_empty
      expect(result.attributes).to eq(
        { 'some_attr' => 'some value' }
      )
    end
  end

  describe '.failure' do
    it 'ensures a Result instance is created with errors, defaults to a generic error' do
      result = described_class.failure(nil)

      expect(result.errors).not_to be_empty
      expect(result.errors.messages).to eq(
        { base: ['An error has occurred'] }
      )
    end

    it 'accepts errors and attributes' do
      result = described_class.failure('some error message', some_attr: 'some value')

      expect(result.errors).not_to be_empty
      expect(result.errors.messages).to eq(
        { base: ['some error message'] }
      )
      expect(result.attributes).to eq(
        { 'some_attr' => 'some value' }
      )
    end
  end
end
