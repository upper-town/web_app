# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NormalizeEmail do
  describe '#call' do
    it 'just removes white spaces and transforms to lower case' do
      [
        [nil, nil],
        ["\n\t \n", ''],

        ['user@example.com',      'user@example.com'],
        ['  USER@example .COM  ', 'user@example.com'],
        [' 1! @# user @ example .COM.net...(ORG)  ', '1!@#user@example.com.net...(org)'],
      ].each do |given_email, expected_email|
        expect(described_class.new(given_email).call).to eq(expected_email)
      end
    end
  end
end
