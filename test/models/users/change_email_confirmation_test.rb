# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailConfirmationTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailConfirmation }

  it "has default values" do
    instance = described_class.new

    assert_nil(instance.email)
    assert_nil(instance.change_email)
    assert_nil(instance.password)

    assert_nil(instance.token)
    assert_nil(instance.code)
  end

  describe "validations with action :create" do
    it "validates email" do
      instance = described_class.new(email: " ")
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:email, :blank))

      instance = described_class.new(email: "a" * 2)
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:email, :too_short))

      instance = described_class.new(email: "a" * 256)
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:email, :too_long))

      instance = described_class.new(email: "xxx@xxx")
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:email, :format_invalid))

      instance = described_class.new(email: "upper@example.com")
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:email, :domain_not_supported))

      instance = described_class.new(email: "user@upper.town")
      instance.action = :create
      instance.validate
      assert_not(instance.errors.key?(:email))
    end

    it "validates change_email" do
      instance = described_class.new(change_email: " ")
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:change_email, :blank))

      instance = described_class.new(change_email: "a" * 2)
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:change_email, :too_short))

      instance = described_class.new(change_email: "a" * 256)
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:change_email, :too_long))

      instance = described_class.new(change_email: "xxx@xxx")
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:change_email, :format_invalid))

      instance = described_class.new(change_email: "upper@example.com")
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:change_email, :domain_not_supported))

      instance = described_class.new(change_email: "user@upper.town")
      instance.action = :create
      instance.validate
      assert_not(instance.errors.key?(:change_email))
    end

    it "validates password" do
      instance = described_class.new(password: " ")
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:password, :blank))

      instance = described_class.new(password: "a" * 256)
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:password, :too_long))

      instance = described_class.new(password: "abcdef123456")
      instance.action = :create
      instance.validate
      assert_not(instance.errors.key?(:password))
    end
  end

  describe "validations with action :update" do
    it "validates token" do
      instance = described_class.new(token: " ")
      instance.action = :update
      instance.validate
      assert(instance.errors.of_kind?(:token, :blank))

      instance = described_class.new(token: "a" * 256)
      instance.action = :update
      instance.validate
      assert(instance.errors.of_kind?(:token, :too_long))

      instance = described_class.new(token: "abcdef123456")
      instance.action = :update
      instance.validate
      assert_not(instance.errors.key?(:token))
    end

    it "validates code" do
      instance = described_class.new(code: " ")
      instance.action = :update
      instance.validate
      assert(instance.errors.of_kind?(:code, :blank))

      instance = described_class.new(code: "A" * 256)
      instance.action = :update
      instance.validate
      assert(instance.errors.of_kind?(:code, :too_long))

      instance = described_class.new(code: "ABCD1234")
      instance.action = :update
      instance.validate
      assert_not(instance.errors.key?(:code))
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
