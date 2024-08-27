# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Servers::VerifyAccounts::ValidateJsonFile do
  it 'initializes with errors not empty before calling #valid? or #invalid?' do
    validator = described_class.new(
      {
        'accounts' => [
          '6e781bfd-353a-4e42-9077-6e5ac6cc477c',
          'b8b22a7a-e7d4-4b5b-b0a3-01406e2d5aad',
        ]
      }
    )

    expect(validator.errors).to include(:not_validated_yet)
  end

  describe '#valid? and #invalid?' do
    context 'when data has invalid schema' do
      it 'returns false and set errors' do
        [
          nil, ' ', 123, {}, [],
          { 'accounts' => nil },
          { 'accounts' => ' ' },
          { 'accounts' => 123 },
          { 'accounts' => {}  },
          { 'other'    => []  },
        ].each do |data|
          validator = described_class.new(data)

          expect(validator).not_to be_valid, "Failed for #{data.inspect}"
          expect(validator).to be_invalid
          expect(validator.errors).to include(:invalid_json_schema)
        end
      end
    end

    context 'when data has invalid accounts size' do
      it 'returns false and set errors' do
        validator = described_class.new({
          'accounts' => [
            'uuid-01',
            'uuid-02',
            'uuid-03',
            'uuid-04',
            'uuid-05',
            'uuid-06',
            'uuid-07',
            'uuid-08',
            'uuid-09',
            'uuid-10',
            'uuid-11',
          ]
        })

        expect(validator).not_to be_valid
        expect(validator).to be_invalid
        expect(validator.errors).to include('must be an array with max size of 10')
      end
    end

    context 'when data has invalid accounts UUIDs format' do
      it 'returns false and set errors' do
        validator = described_class.new({
          'accounts' => [
            'uuid-01',
            'ffaf9cfd-72e0-461f-ba12-42c2d080c2c3',
          ]
        })

        expect(validator).not_to be_valid
        expect(validator).to be_invalid
        expect(validator.errors).to include('must contain valid Account UUIDs')
      end
    end

    context 'when data has duplicated accounts UUIDs' do
      it 'returns false and set errors' do
        validator = described_class.new({
          'accounts' => [
            'ffaf9cfd-72e0-461f-ba12-42c2d080c2c3',
            'ffaf9cfd-72e0-461f-ba12-42c2d080c2c3',
            '2aaeecfc-be65-4c45-9797-1db4a8a9fa5e',
          ]
        })

        expect(validator).not_to be_valid
        expect(validator).to be_invalid
        expect(validator.errors).to include('must be an array with non-duplicated Account UUIDs')
      end
    end

    context 'when data has an empty accounts' do
      it 'returns true and does not set errors' do
        validator = described_class.new({
          'accounts' => []
        })

        expect(validator).to be_valid
        expect(validator).not_to be_invalid
        expect(validator.errors).to be_empty
      end
    end

    context 'when data accounts array has valid UUID strings' do
      it 'returns true and does not set errors' do
        validator = described_class.new({
          'accounts' => [
            '9acfa883-2554-4547-9eba-86736e05e036',
            '353b2e46-d352-4ed7-80a5-1486ba3e8d56',
            'd8a577de-1620-4229-878c-75db1fb626b1',
            '241d30ea-6d19-48f5-889d-ff565cdac7e5',
          ]
        })

        expect(validator).to be_valid
        expect(validator).not_to be_invalid
        expect(validator.errors).to be_empty
      end
    end
  end
end
