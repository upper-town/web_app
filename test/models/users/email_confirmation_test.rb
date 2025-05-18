# frozen_string_literal: true

require "test_helper"

class Users::EmailConfirmationTest < ActiveSupport::TestCase
  let(:described_class) { Users::EmailConfirmation }

  it "has default values" do
    instance = described_class.new

    assert_nil(instance.email)
  end

  describe "validations" do
    it "validates email" do
      instance = described_class.new(email: " ")
      instance.validate
      assert(instance.errors.of_kind?(:email, :blank))

      instance = described_class.new(email: "a" * 2)
      instance.validate
      assert(instance.errors.of_kind?(:email, :too_short))

      instance = described_class.new(email: "a" * 256)
      instance.validate
      assert(instance.errors.of_kind?(:email, :too_long))

      instance = described_class.new(email: "user@upper.town")
      instance.validate
      assert_not(instance.errors.key?(:email))
    end
  end

  describe "normalizations" do
    it "normalizes email" do
      instance = described_class.new(email: nil)

      assert_nil(instance.email)

      instance = described_class.new(email: "\n\t USER  @UPPER .Town \n")

      assert_equal("user@upper.town", instance.email)
    end
  end
end
