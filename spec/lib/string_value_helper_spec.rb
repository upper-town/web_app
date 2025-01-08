# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StringValueHelper do
  describe '.to_boolean' do
    it 'converts string value to boolean' do
      [
        ['',         false],
        ['  ',       false],
        ['anything', false],

        ['true',    true],
        ['t',       true],
        ['1',       true],
        ['on',      true],
        ['enabled', true],

        [" true \n",    true],
        [" t \n",       true],
        [" 1 \n",       true],
        [" on \n",      true],
        [" enabled \n", true],

        ['TRUE',    true],
        ['T',       true],
        ['ON',      true],
        ['ENABLED', true],

        [" TRUE \n",    true],
        [" T \n",       true],
        [" ON \n",      true],
        [" ENABLED \n", true],
      ].each do |value, expected_boolean|
        returned = described_class.to_boolean(value)

        expect(returned).to(eq(expected_boolean), "Failed for #{value.inspect}")
      end
    end
  end

  describe '.remove_whitespaces' do
    it 'removes all whitespaces from string' do
      [
        ['',       ''],
        [" \n\t ", ''],

        ['something',            'something'],
        ["\n\t some \tthing \n", 'something'],
      ].each do |value, expected_str|
        returned = described_class.remove_whitespaces(value)

        expect(returned).to(eq(expected_str), "Failed for #{value.inspect}")
      end
    end
  end

  describe '.normalize_whitespaces' do
    it 'normalizes whitespaces in string' do
      [
        ['',       ''],
        [" \n\t ", ''],

        ['some thing',           'some thing'],
        ["\n\t some \tthing \n", 'some thing'],
      ].each do |value, expected_str|
        returned = described_class.normalize_whitespaces(value)

        expect(returned).to(eq(expected_str), "Failed for #{value.inspect}")
      end
    end
  end

  describe '.values_list_uniq' do
    it 'returns an array of strings' do
      [
        ['',       ',', true, []],
        [" \n\t ", ',', true, []],

        ['some thing,anything', ',', true,  ['something',  'anything']],
        ['some thing,anything', ',', false, ['some thing', 'anything']],

        ["\n\t some\tthing\n, anything \n, , anything", ',', true,  ['something',  'anything']],
        ["\n\t some\tthing\n, anything \n, , anything", ',', false, ['some thing', 'anything']],
      ].each do |value, separator, remove_whitespaces, expected_array|
        returned = described_class.values_list_uniq(value, separator, remove_whitespaces)

        expect(returned).to(
          eq(expected_array),
          "Failed for value=#{value.inspect} and remove_whitespaces=#{remove_whitespaces.inspect}"
        )
      end
    end
  end
end
