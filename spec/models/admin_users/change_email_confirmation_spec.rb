require 'rails_helper'

RSpec.describe AdminUsers::ChangeEmailConfirmation do
  it 'has default values' do
    instance = described_class.new

    expect(instance.email).to be_nil
    expect(instance.change_email).to be_nil
    expect(instance.password).to be_nil
  end

  describe 'validations' do
    it 'validates email' do
      instance = described_class.new(email: ' ')
      instance.validate
      expect(instance.errors.of_kind?(:email, :blank)).to be(true)

      instance = described_class.new(email: 'a' * 2)
      instance.validate
      expect(instance.errors.of_kind?(:email, :too_short)).to be(true)

      instance = described_class.new(email: 'a' * 256)
      instance.validate
      expect(instance.errors.of_kind?(:email, :too_long)).to be(true)

      instance = described_class.new(email: 'user@upper.town')
      instance.validate
      expect(instance.errors.key?(:email)).to be(false)
    end

    it 'validates change_email' do
      instance = described_class.new(change_email: ' ')
      instance.validate
      expect(instance.errors.of_kind?(:change_email, :blank)).to be(true)

      instance = described_class.new(change_email: 'a' * 2)
      instance.validate
      expect(instance.errors.of_kind?(:change_email, :too_short)).to be(true)

      instance = described_class.new(change_email: 'a' * 256)
      instance.validate
      expect(instance.errors.of_kind?(:change_email, :too_long)).to be(true)

      instance = described_class.new(change_email: 'user@upper.town')
      instance.validate
      expect(instance.errors.key?(:change_email)).to be(false)
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
    it 'normalizes email' do
      instance = described_class.new(email: nil)

      expect(instance.email).to be_nil

      instance = described_class.new(email: "\n\t USER  @UPPER .Town \n")

      expect(instance.email).to eq('user@upper.town')
    end

    it 'normalizes change_email' do
      instance = described_class.new(change_email: nil)

      expect(instance.change_email).to be_nil

      instance = described_class.new(change_email: "\n\t USER  @UPPER .Town \n")

      expect(instance.change_email).to eq('user@upper.town')
    end
  end
end
