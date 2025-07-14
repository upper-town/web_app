# frozen_string_literal: true

require "test_helper"

class AdminUsers::PasswordResetTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::PasswordReset }

  it "has default values" do
    instance = described_class.new

    assert_nil(instance.email)
    assert_nil(instance.token)
    assert_nil(instance.code)
    assert_nil(instance.password)
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

      instance = described_class.new(email: "admin_user@example.com")
      instance.action = :create
      instance.validate
      assert(instance.errors.of_kind?(:email, :domain_not_supported))

      instance = described_class.new(email: "admin_user@upper.town")
      instance.action = :create
      instance.validate
      assert_not(instance.errors.key?(:email))
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

      instance = described_class.new(code: "a" * 256)
      instance.action = :update
      instance.validate
      assert(instance.errors.of_kind?(:code, :too_long))

      instance = described_class.new(code: "abcdef123456")
      instance.action = :update
      instance.validate
      assert_not(instance.errors.key?(:code))
    end

    it "validates password" do
      instance = described_class.new(password: " ")
      instance.action = :update
      instance.validate
      assert(instance.errors.of_kind?(:password, :blank))

      instance = described_class.new(password: "a" * 7)
      instance.action = :update
      instance.validate
      assert(instance.errors.of_kind?(:password, :too_short))

      instance = described_class.new(password: "a" * 73)
      instance.action = :update
      instance.validate
      assert(instance.errors.of_kind?(:password, :too_long))

      instance = described_class.new(password: "abcdef123456")
      instance.action = :update
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
