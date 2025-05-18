# frozen_string_literal: true

require "test_helper"

class AdminUsers::ChangeEmailConfirmationTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::ChangeEmailConfirmation }

  it "has default values" do
    instance = described_class.new

    assert_nil(instance.email)
    assert_nil(instance.change_email)
    assert_nil(instance.password)
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

    it "validates change_email" do
      instance = described_class.new(change_email: " ")
      instance.validate
      assert(instance.errors.of_kind?(:change_email, :blank))

      instance = described_class.new(change_email: "a" * 2)
      instance.validate
      assert(instance.errors.of_kind?(:change_email, :too_short))

      instance = described_class.new(change_email: "a" * 256)
      instance.validate
      assert(instance.errors.of_kind?(:change_email, :too_long))

      instance = described_class.new(change_email: "user@upper.town")
      instance.validate
      assert_not(instance.errors.key?(:change_email))
    end

    it "validates password" do
      instance = described_class.new(password: " ")
      instance.validate
      assert(instance.errors.of_kind?(:password, :blank))

      instance = described_class.new(password: "a" * 256)
      instance.validate
      assert(instance.errors.of_kind?(:password, :too_long))

      instance = described_class.new(password: "abcdef123456")
      instance.validate
      assert_not(instance.errors.key?(:password))
    end
  end

  describe "normalizations" do
    it "normalizes email" do
      instance = described_class.new(email: nil)

      assert_nil(instance.email)

      instance = described_class.new(email: "\n\t USER  @UPPER .Town \n")

      assert_equal("user@upper.town", instance.email)
    end

    it "normalizes change_email" do
      instance = described_class.new(change_email: nil)

      assert_nil(instance.change_email)

      instance = described_class.new(change_email: "\n\t USER  @UPPER .Town \n")

      assert_equal("user@upper.town", instance.change_email)
    end
  end
end
