require 'rails_helper'

RSpec.describe Users::PasswordReset do
  it 'has default values' do
    instance = described_class.new

    expect(instance.email).to be_nil
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
  end

  describe 'normalizations' do
    it 'normalizes email' do
      instance = described_class.new(email: nil)

      expect(instance.email).to be_nil

      instance = described_class.new(email: "\n\t USER  @UPPER .Town \n")

      expect(instance.email).to eq('user@upper.town')
    end
  end
end
