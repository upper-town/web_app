# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailReversionEditTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailReversionEdit }

  it "has default values" do
    instance = described_class.new

    assert_nil(instance.token)
    assert_not(instance.auto_click)
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
  end

  describe "normalizations" do
    it "normalizes token" do
      instance = described_class.new(token: nil)

      assert_nil(instance.token)

      instance = described_class.new(token: "\n\t Aaaa1234 B  bbb 5678\n")

      assert_equal("Aaaa1234Bbbb5678", instance.token)
    end
  end
end
