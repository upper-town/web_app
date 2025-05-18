require 'rails_helper'

RSpec.describe Result do
  describe '#initialize' do
    it 'has default values for errors and data' do
      result = described_class.new

      expect(result.errors).to be_empty
      expect(result.errors).to be_a(ActiveModel::Errors)

      expect(result.data).to be_empty
      expect(result.data).to be_a(Hash)
      expect(result.data.object_id).to eq(result.attributes.object_id)
    end

    describe 'setting errors' do
      it 'sets errors from Hash with Symbol, String, Number or Array values, and skips blanks' do
        result = described_class.new(
          {
            error_code_1: 'error message',
            error_code_2: :invalid,
            error_code_3: 123456,
            error_code_4: ' ',
            error_code_5: false,
            error_code_6: nil,
            error_code_7: [],
            error_code_8: [ 'error message', :invalid, 123456, ' ', false, nil ]
          }
        )

        expect(result.errors.of_kind?(:error_code_1, 'error message')).to be(true)
        expect(result.errors.of_kind?(:error_code_2, :invalid)).to be(true)
        expect(result.errors.of_kind?(:error_code_3, '123456')).to be(true)
        expect(result.errors.of_kind?(:error_code_8, 'error message')).to be(true)
        expect(result.errors.of_kind?(:error_code_8, :invalid)).to be(true)
        expect(result.errors.of_kind?(:error_code_8, '123456')).to be(true)
        expect(result.errors.messages).to eq(
          {
            error_code_1: [ 'error message' ],
            error_code_2: [ 'is invalid' ],
            error_code_3: [ '123456' ],
            error_code_8: [ 'error message', 'is invalid', '123456' ]
          }
        )
      end

      it 'sets errors from Array, and skips blanks' do
        result = described_class.new(
          [ 'error message', :invalid, 123456, ' ', false, nil ]
        )

        expect(result.errors.of_kind?(:base, 'error message')).to be(true)
        expect(result.errors.of_kind?(:base, :invalid)).to be(true)
        expect(result.errors.of_kind?(:base, '123456')).to be(true)
        expect(result.errors.messages).to eq(
          { base: [ 'error message', 'is invalid', '123456' ] },
        )
      end

      it 'sets errors from String, Symbol, Numeric, and skips blanks' do
        [
          [ 'error message', 'error message', { base: [ 'error message' ] } ],
          [ :invalid,        :invalid,        { base: [ 'is invalid' ] } ],
          [ 123456,          '123456',        { base: [ '123456' ]  } ],
          [ 1234.56,         '1234.56',       { base: [ '1234.56' ] } ]
        ].each do |error_value, expected_type, expected_messages|
          result = described_class.new(error_value)

          expect(result.errors.of_kind?(:base, expected_type)).to(
            be(true), "Failed for #{error_value.inspect}"
          )
          expect(result.errors.messages).to eq(expected_messages)
        end

        [ ' ', '', :'', false, nil ].each do |blank_error_value|
          result = described_class.new(blank_error_value)

          expect(result.errors).to(be_empty, "Failed for #{blank_error_value.inspect}")
        end
      end

      it 'sets errors from ActiveModel::Errors' do
        active_model_errors = ActiveModel::Errors.new(generic_model_class.new)
        active_model_errors.add(:name, 'error message')
        active_model_errors.add(:description, :invalid)

        result = described_class.new(active_model_errors)

        expect(result.errors.of_kind?(:name, 'error message')).to be(true)
        expect(result.errors.of_kind?(:description, :invalid)).to be(true)
        expect(result.errors.messages).to eq(
          {
            name: [ 'error message' ],
            description: [ 'is invalid' ]
          }
        )
      end

      it 'sets errors from true with a generic message' do
        result = described_class.new(true)

        expect(result.errors.of_kind?(:base, :generic_error)).to be(true)
        expect(result.errors.messages).to eq({ base: [ 'An error has occurred' ] })
      end

      it 'does not set errors from nil, false' do
        [ nil, false ].each do |nil_or_false_error_value|
          result = described_class.new(nil_or_false_error_value)

          expect(result.errors).to(be_empty, "Failed for #{nil_or_false_error_value.inspect}")
        end
      end

      it 'raises an exception when errors class is invalid' do
        expect do
          described_class.new(Time.current)
        end.to raise_exception(
          /Could not build_active_model_errors for Result: invalid error_values\.class/
        )
      end
    end

    describe 'setting data' do
      it 'uses with_indifferent_access' do
        result = described_class.new(
          nil,
          {
            attr: 'value',
            'another attr' => 'another value',
            42 => 'forty two'
          }
        )

        expect(result.data['attr']).to eq('value')
        expect(result.data[:'another attr']).to eq('another value')
        expect(result.data[42]).to eq('forty two')

        expect(result.data).to eq(
          {
            'attr' => 'value',
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
      result = described_class.new('error message')

      expect(result.errors).not_to be_empty
      expect(result.success?).to eq(false)
    end
  end

  describe '#failure?' do
    it 'returns true when #errors is not empty' do
      result = described_class.new('error message')

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
    it 'adds to errors from Hash with Symbol, String, Number or Array values, and skips blanks' do
      result = described_class.new('existing error message')

      result.add_errors(
        {
          error_code_1: 'error message',
          error_code_2: :invalid,
          error_code_3: 123456,
          error_code_4: ' ',
          error_code_5: false,
          error_code_6: nil,
          error_code_7: [],
          error_code_8: [ 'error message', :invalid, 123456, ' ', false, nil ]
        }
      )

      expect(result.errors.of_kind?(:base, 'existing error message')).to be(true)
      expect(result.errors.of_kind?(:error_code_1, 'error message')).to be(true)
      expect(result.errors.of_kind?(:error_code_2, :invalid)).to be(true)
      expect(result.errors.of_kind?(:error_code_3, '123456')).to be(true)
      expect(result.errors.of_kind?(:error_code_8, 'error message')).to be(true)
      expect(result.errors.of_kind?(:error_code_8, :invalid)).to be(true)
      expect(result.errors.of_kind?(:error_code_8, '123456')).to be(true)
      expect(result.errors.messages).to eq(
        {
          base: [ 'existing error message' ],
          error_code_1: [ 'error message' ],
          error_code_2: [ 'is invalid' ],
          error_code_3: [ '123456' ],
          error_code_8: [ 'error message', 'is invalid', '123456' ]
        }
      )
    end

    it 'adds to errors from Array, and skips blanks' do
      result = described_class.new('existing error message')

      result.add_errors(
        [ 'error message', :invalid, 123456, ' ', false, nil ]
      )

      expect(result.errors.of_kind?(:base, 'existing error message')).to be(true)
      expect(result.errors.of_kind?(:base, 'error message')).to be(true)
      expect(result.errors.of_kind?(:base, :invalid)).to be(true)
      expect(result.errors.of_kind?(:base, '123456')).to be(true)
      expect(result.errors.messages).to eq(
        { base: [ 'existing error message', 'error message', 'is invalid', '123456' ] },
      )
    end

    it 'adds to errors from String, Symbol, Numeric, and skips blanks' do
      [
        [ 'error message', [ 'existing error message', 'error message' ], { base: [ 'existing error message', 'error message' ] } ],
        [ :invalid,        [ 'existing error message', :invalid ],        { base: [ 'existing error message', 'is invalid' ] } ],
        [ 123456,          [ 'existing error message', '123456' ],        { base: [ 'existing error message', '123456' ]  } ],
        [ 1234.56,         [ 'existing error message', '1234.56' ],       { base: [ 'existing error message', '1234.56' ] } ]
      ].each do |error_value, expected_error_types, expected_error_messages|
        result = described_class.new('existing error message')

        result.add_errors(error_value)

        expected_error_types.each do |expected_type|
          expect(result.errors.of_kind?(:base, expected_type)).to(be(true), "Failed for #{error_value.inspect}")
        end
        expect(result.errors.messages).to eq(expected_error_messages)
      end

      [ ' ', '', :'', false, nil ].each do |blank_error_value|
        result = described_class.new('existing error message')

        result.add_errors(blank_error_value)

        expect(result.errors.of_kind?(:base, 'existing error message')).to(
          be(true), "Failed for #{blank_error_value.inspect}"
        )
        expect(result.errors.messages).to eq(
          { base: [ 'existing error message' ] }
        )
      end
    end

    it 'adds to errors from ActiveModel::Errors' do
      active_model_errors = ActiveModel::Errors.new(generic_model_class.new)
      active_model_errors.add(:name, 'error message')
      active_model_errors.add(:description, :invalid)

      result = described_class.new('existing error message')

      result.add_errors(active_model_errors)

      expect(result.errors.of_kind?(:base, 'existing error message')).to be(true)
      expect(result.errors.of_kind?(:name, 'error message')).to be(true)
      expect(result.errors.of_kind?(:description, :invalid)).to be(true)
      expect(result.errors.messages).to eq(
        {
          base: [ 'existing error message' ],
          name: [ 'error message' ],
          description: [ 'is invalid' ]
        }
      )
    end

    it 'adds to errors from true with a generic message' do
      result = described_class.new('existing error message')

      result.add_errors(true)

      expect(result.errors.of_kind?(:base, :generic_error)).to be(true)
      expect(result.errors.of_kind?(:base, 'existing error message')).to be(true)
      expect(result.errors.messages).to eq(
        { base: [ 'existing error message', 'An error has occurred' ] }
      )
    end

    it 'does not add to errors from nil, false' do
      [ nil, false ].each do |nil_or_false_error_value|
        result = described_class.new('existing error message')

        result.add_errors(nil_or_false_error_value)

        expect(result.errors.of_kind?(:base, 'existing error message')).to(
          be(true), "Failed for #{nil_or_false_error_value.inspect}"
        )
        expect(result.errors.messages).to eq(
          { base: [ 'existing error message' ] }
        )
      end
    end

    it 'raises an error when errors class is invalid' do
      expect do
        result = described_class.new('existing error message')
        result.add_errors(Time.current)
      end.to raise_error(
        /Could not build_active_model_errors for Result: invalid error_values\.class/
      )
    end
  end

  describe '.success' do
    it 'creates an instance with empty errors and empty data' do
      result = described_class.success

      expect(result.errors).to be_empty
      expect(result.data).to be_empty
    end

    it 'accepts only data' do
      result = described_class.success(attr: 'value')

      expect(result.errors).to be_empty
      expect(result.data).to eq(
        { 'attr' => 'value' }
      )
    end
  end

  describe '.failure' do
    it 'ensures a Result instance is created with errors, defaults to a generic error' do
      result = described_class.failure(nil)

      expect(result.errors.of_kind?(:base, :generic_error)).to be(true)
      expect(result.errors.messages).to eq(
        { base: [ 'An error has occurred' ] }
      )
    end

    it 'accepts errors and data' do
      result = described_class.failure('error message', attr: 'value')

      expect(result.errors.of_kind?(:base, 'error message')).to be(true)
      expect(result.errors.messages).to eq({ base: [ 'error message' ] })
      expect(result.data).to eq({ 'attr' => 'value' })
    end
  end

  def generic_model_class
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.name
        'GenericModelClass'
      end

      attribute :name
      attribute :description
    end
  end
end
