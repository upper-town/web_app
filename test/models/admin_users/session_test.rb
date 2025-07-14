# frozen_string_literal: true

require "test_helper"

class AdminUsers::SessionTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::Session }

  it "has default values" do
    instance = described_class.new

    assert_nil(instance.email)
    assert_nil(instance.password)
    assert_not(instance.remember_me)
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

      instance = described_class.new(email: "xxx@xxx")
      instance.validate
      assert(instance.errors.of_kind?(:email, :format_invalid))

      instance = described_class.new(email: "admin_user@example.com")
      instance.validate
      assert(instance.errors.of_kind?(:email, :domain_not_supported))

      instance = described_class.new(email: "admin_user@upper.town")
      instance.validate
      assert_not(instance.errors.key?(:email))
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

      instance = described_class.new(email: "\n\t Admin_USER  @UPPER .Town \n")
      assert_equal("admin_user@upper.town", instance.email)
    end
  end
end
