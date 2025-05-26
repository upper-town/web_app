# frozen_string_literal: true

require "test_helper"

class Users::EmailConfirmationTest < ActiveSupport::TestCase
  let(:described_class) { Users::EmailConfirmation }

  it "has default values" do
    instance = described_class.new

    assert_nil(instance.token)
    assert_nil(instance.code)
  end

  describe "validations" do
    it "validates token" do
      instance = described_class.new(token: " ")
      instance.validate
      assert(instance.errors.of_kind?(:token, :blank))

      instance = described_class.new(token: "a" * 256)
      instance.validate
      assert(instance.errors.of_kind?(:token, :too_long))

      instance = described_class.new(token: "abcdef123456")
      instance.validate
      assert_not(instance.errors.key?(:token))
    end

    it "validates code" do
      instance = described_class.new(code: " ")
      instance.validate
      assert(instance.errors.of_kind?(:code, :blank))

      instance = described_class.new(code: "a" * 256)
      instance.validate
      assert(instance.errors.of_kind?(:code, :too_long))

      instance = described_class.new(code: "abcdef123456")
      instance.validate
      assert_not(instance.errors.key?(:code))
    end
  end

  describe "normalizations" do
    it "normalizes token" do
      instance = described_class.new(token: nil)

      assert_nil(instance.token)

      instance = described_class.new(token: "\n\t Aaaa1234 B  bbb 5678\n")

      assert_equal("Aaaa1234Bbbb5678", instance.token)
    end

    it "normalizes code" do
      instance = described_class.new(code: nil)

      assert_nil(instance.code)

      instance = described_class.new(code: "\n\t Aa11 B  b2 2\n")

      assert_equal("AA11BB22", instance.code)
    end
  end
end
