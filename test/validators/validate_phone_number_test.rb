# frozen_string_literal: true

require "test_helper"

class ValidatePhoneNumberTest < ActiveSupport::TestCase
  let(:described_class) { ValidatePhoneNumber }

  it "initializes with errors not empty before calling #valid? or #invalid?" do
    validator = described_class.new("+1 (202) 555-9999")

    assert_includes(validator.errors, :not_validated_yet)
  end

  describe "#valid? and #invalid?" do
    describe "when phone number is not valid" do
      it "returns false and sets errors" do
        [
          nil,
          "",
          " \n\t",
          "aaa",
          "0",
          "000",
          "1",
          "111"
        ].each do |invaild_phone_number|
          validator = described_class.new(invaild_phone_number)

          assert_not(validator.valid?, "Failed for #{invaild_phone_number.inspect}")
          assert(validator.invalid?)
          assert_includes(validator.errors, :not_valid)
        end
      end
    end

    describe "when phone number is valid" do
      it "returns true and does not set errors" do
        [
          "202-555-9999",
          "(202) 555-9999",
          "(202)555-9999",
          "+1-202-555-9999",
          "+1 (202) 555-9999",
          "+1(202)555-9999",
          "+12025559999",

          "16-95555-9999",
          "(16) 95555-9999",
          "(16)95555-9999",
          "+55-16-95555-9999",
          "+55 (16) 95555-9999",
          "+55(16)95555-9999",
          "+5516955559999"
        ].each do |valid_phone_number|
          validator = described_class.new(valid_phone_number)

          assert(validator.valid?, "Failed for #{valid_phone_number.inspect}")
          assert_not(validator.invalid?)
          assert_empty(validator.errors)
        end
      end
    end
  end

  describe "#phone_number" do
    it "returns the given phone number value string" do
      assert_equal("", described_class.new(nil).phone_number)
      assert_equal("", described_class.new("").phone_number)

      assert_equal("abcdef", described_class.new("abcdef").phone_number)
      assert_equal("+1 (202) 555-9999", described_class.new("+1 (202) 555-9999").phone_number)
    end
  end
end
