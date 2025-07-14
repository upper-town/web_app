# frozen_string_literal: true

require "test_helper"

class ValidateEmailTest < ActiveSupport::TestCase
  let(:described_class) { ValidateEmail }

  it "initializes with errors not empty before calling #valid? or #invalid?" do
    validator = described_class.new("user@gmail.com")

    assert_includes(validator.errors, :not_yet_validated)
  end

  describe "#valid? and #invalid?" do
    describe "when email format is not valid" do
      it "returns false and set errors" do
        [
          nil,
          "",
          " \n\t",
          "user",
          "user@",
          "user@gmail",
          "user@sub1.sub2.sub3.sub4.gmail.com",
          ".user@@gmail.com",
          "_user@@gmail.com",
          "user@@gmail.com",
          'user#@gmail.com',
          "user+test@gmail.com",
          "user,test@gmail.com"
        ].each do |invalid_email|
          validator = described_class.new(invalid_email)

          assert_not(validator.valid?, "Failed for #{invalid_email.inspect}")
          assert(validator.invalid?)
          assert_includes(validator.errors, :format_invalid)
        end
      end

      it "returns false and set errors for long email" do
        invalid_long_email =
          "userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@" \
          "sub1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
          "sub2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
          "sub3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
          "googlexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
          "comxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

        validator = described_class.new(invalid_long_email)

        assert_not(validator.valid?)
        assert(validator.invalid?)
        assert_includes(validator.errors, :format_invalid)
      end
    end

    describe "reserved names" do
      describe "when email contains reserved name" do
        it "returns accordingly" do
          %w[
            example
            local
            localhost
          ].each do |reserved_name|
            [
              [false, "user@sub.#{reserved_name}"],
              [false, "user@#{reserved_name}.com"],

              [false, "user@sub.sub.#{reserved_name}"],
              [false, "user@sub.#{reserved_name}.com"],
              [false, "user@#{reserved_name}.sub.com"],

              [false, "user@sub.sub.sub.#{reserved_name}"],
              [false, "user@sub.sub.#{reserved_name}.com"],
              [false, "user@sub.#{reserved_name}.sub.com"],
              [true,  "user@#{reserved_name}.sub.sub.com"],

              [false, "user@sub.sub.sub.sub.#{reserved_name}"],
              [false, "user@sub.sub.sub.#{reserved_name}.com"],
              [false, "user@sub.sub.#{reserved_name}.sub.com"],
              [true,  "user@sub.#{reserved_name}.sub.sub.com"],
              [true,  "user@#{reserved_name}.sub.sub.sub.com"]
            ].each do |valid, email_with_reserved_domain|
              validator = described_class.new(email_with_reserved_domain)

              if valid
                assert(
                  validator.valid?,
                  "Failed for #{reserved_name.inspect} and #{email_with_reserved_domain.inspect}"
                )
                assert_not(validator.invalid?)
                assert_empty(validator.errors)
              else
                assert_not(
                  validator.valid?,
                  "Failed for #{reserved_name.inspect} and #{email_with_reserved_domain.inspect}"
                )
                assert(validator.invalid?)
                assert_includes(validator.errors, :domain_not_supported)
              end
            end
          end
        end
      end
    end

    describe "when email domain is from a disposable email service" do
      it "returns false and set errors" do
        ["zzz.com"].each do |disposable_email_host|
          disposable_email = "user@#{disposable_email_host}"

          validator = described_class.new(disposable_email)

          assert_not(validator.valid?)
          assert(validator.invalid?)
          assert_includes(validator.errors, :domain_not_supported)
        end
      end
    end

    describe "when email is valid" do
      it "returns true and does not set errors" do
        [
          "user@gmail.com",
          "USER@GMAIL.COM",
          "user@sub1.sub2.sub3.gmail.com",
          "user.test@gmail.com",
          "user-test@gmail.com",
          "user_test@gmail.com",
          "userxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@" \
            "gmailxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
            "com1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
            "com2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
            "com3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        ].each do |valid_email|
          validator = described_class.new(valid_email)

          assert(validator.valid?, "Failed for #{valid_email.inspect}")
          assert_not(validator.invalid?)
          assert_empty(validator.errors)
        end
      end
    end
  end

  describe "#email" do
    it "returns the given email value string" do
      assert_equal("", described_class.new(nil).email)
      assert_equal("", described_class.new("").email)

      assert_equal("abcdef", described_class.new("abcdef").email)
      assert_equal("user@upper.town", described_class.new("user@upper.town").email)
    end
  end
end
