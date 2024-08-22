# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::PasswordResetEdit do
  it 'has default values' do
    instance = described_class.new

    expect(instance.token).to be_nil
    expect(instance.password).to be_nil
  end

  describe 'validations' do
    it 'validates token' do
      instance = described_class.new(token: ' ')
      instance.validate
      expect(instance.errors.of_kind?(:token, :blank)).to be(true)

      instance = described_class.new(token: 'a' * 256)
      instance.validate
      expect(instance.errors.of_kind?(:token, :too_long)).to be(true)

      instance = described_class.new(token: 'abcdef123456')
      instance.validate
      expect(instance.errors.key?(:token)).to be(false)
    end

    it 'validates password' do
      instance = described_class.new(password: ' ')
      instance.validate
      expect(instance.errors.of_kind?(:password, :blank)).to be(true)

      instance = described_class.new(password: 'a' * 256)
      instance.validate
      expect(instance.errors.of_kind?(:password, :too_long)).to be(true)

      instance = described_class.new(password: 'abcdef123456')
      instance.validate
      expect(instance.errors.key?(:password)).to be(false)
    end
  end

  describe 'normalizations' do
    it 'normalizes token' do
      instance = described_class.new(token: nil)

      expect(instance.token).to be_nil

      instance = described_class.new(token: "\n\t Aaaa1234 B  bbb 5678\n")

      expect(instance.token).to eq('Aaaa1234Bbbb5678')
    end
  end
end
