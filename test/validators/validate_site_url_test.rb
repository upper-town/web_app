# frozen_string_literal: true

require "test_helper"

class ValidateSiteUrlTest < ActiveSupport::TestCase
  let(:described_class) { ValidateSiteUrl }

  it "initializes with errors not empty before calling #valid? or #invalid?" do
    validator = described_class.new("https://google.com/")

    assert_includes(validator.errors, :not_yet_validated)
  end

  describe "#valid? and #invalid?" do
    describe "when site_url format is not valid" do
      it "returns false and set errors" do
        [
          nil,
          "",
          " \n\t",
          "ftp://",
          "ftp://google",
          "ftp://google.com",
          "https://sub1.sub2.sub3.sub4.sub5.sub6.com"
        ].each do |invalid_site_url|
          validator = described_class.new(invalid_site_url)

          assert_not(validator.valid?, "Failed for #{invalid_site_url.inspect}")
          assert(validator.invalid?)
          assert_includes(validator.errors, :format_invalid)
        end
      end
    end

    it "returns false and set errors for long site_url" do
      invalid_long_site_url =
        "https://" \
        "sub1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
        "sub2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
        "sub3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
        "sub4xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
        "sub5xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
        "comxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

      validator = described_class.new(invalid_long_site_url)

      assert_not(validator.valid?)
      assert(validator.invalid?)
      assert_includes(validator.errors, :format_invalid)
    end

    describe "reserved names" do
      describe "when site_url contains reserved name" do
        it "returns accordingly" do
          %w[
            corp
            domain
            example
            home
            host
            internal
            intranet
            invalid
            lan
            local
            localdomain
            localhost
            onion
            private
            test
          ].each do |reserved_name|
            [
              [false, "https://sub.#{reserved_name}"],
              [false, "https://#{reserved_name}.com"],

              [false, "https://sub.sub.#{reserved_name}"],
              [false, "https://sub.#{reserved_name}.com"],
              [false, "https://#{reserved_name}.sub.com"],

              [false, "https://sub.sub.sub.#{reserved_name}"],
              [false, "https://sub.sub.#{reserved_name}.com"],
              [false, "https://sub.#{reserved_name}.sub.com"],
              [true,  "https://#{reserved_name}.sub.sub.com"],

              [false, "https://sub.sub.sub.sub.#{reserved_name}"],
              [false, "https://sub.sub.sub.#{reserved_name}.com"],
              [false, "https://sub.sub.#{reserved_name}.sub.com"],
              [true,  "https://sub.#{reserved_name}.sub.sub.com"],
              [true,  "https://#{reserved_name}.sub.sub.sub.com"],

              [false, "https://sub.sub.sub.sub.sub.#{reserved_name}"],
              [false, "https://sub.sub.sub.sub.#{reserved_name}.com"],
              [false, "https://sub.sub.sub.#{reserved_name}.sub.com"],
              [true,  "https://sub.sub.#{reserved_name}.sub.sub.com"],
              [true,  "https://sub.#{reserved_name}.sub.sub.sub.com"],
              [true,  "https://#{reserved_name}.sub.sub.sub.sub.com"]
            ].each do |valid, site_url_with_reserved_domain|
              validator = described_class.new(site_url_with_reserved_domain)

              if valid
                assert(
                  validator.valid?,
                  "Failed for #{reserved_name.inspect} and #{site_url_with_reserved_domain.inspect}"
                )
                assert_not(validator.invalid?)
                assert_empty(validator.errors)
              else
                assert_not(
                  validator.valid?,
                  "Failed for #{reserved_name.inspect} and #{site_url_with_reserved_domain.inspect}"
                )
                assert(validator.invalid?)
                assert_includes(validator.errors, :domain_not_supported)
              end
            end
          end
        end
      end
    end

    describe "when site_url is valid" do
      it "returns true and does not set errors" do
        [
          "http://sub1.com/",
          "http://sub1.sub2.com/",
          "http://sub1.sub2.sub3.com/",
          "http://sub1.sub2.sub3.sub4.com/",
          "http://sub1.sub2.sub3.sub4.sub5.com/",

          "https://sub1.com",
          "https://sub1.sub2.com",
          "https://sub1.sub2.sub3.com",
          "https://sub1.sub2.sub3.sub4.com",
          "https://sub1.sub2.sub3.sub4.sub5.com",

          "https://" \
            "sub1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
            "sub2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
            "sub3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
            "sub4xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
            "sub5xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx." \
            "comxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        ].each do |valid_site_url|
          validator = described_class.new(valid_site_url)

          assert(validator.valid?, "Failed for #{valid_site_url.inspect}")
          assert_not(validator.invalid?)
          assert_empty(validator.errors)
        end
      end
    end
  end

  describe "#site_url" do
    it "returns the given site_url value string" do
      assert_equal("", described_class.new(nil).site_url)
      assert_equal("", described_class.new("").site_url)

      assert_equal("abcdef", described_class.new("abcdef").site_url)
      assert_equal("https://google.com", described_class.new("https://google.com").site_url)
    end
  end
end
