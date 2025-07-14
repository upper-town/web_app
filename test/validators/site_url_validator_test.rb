# frozen_string_literal: true

require "test_helper"

class SiteUrlValidatorTest < ActiveSupport::TestCase
  let(:described_class) { SiteUrlValidator }

  describe "#validate" do
    describe "when record has an invalid site_url" do
      it "sets record.errors" do
        record = generic_model_class.new(site_url: "abcdef")

        validator = described_class.new(attributes: [:site_url])
        validator.validate(record)

        assert(record.errors.of_kind?(:site_url, :format_invalid))
      end
    end

    describe "when record has a blank site_url" do
      it "does not record.errors" do
        record = generic_model_class.new(site_url: " ")

        validator = described_class.new(attributes: [:site_url])
        validator.validate(record)

        assert_not(record.errors.of_kind?(:site_url))
      end
    end

    describe "when record has a valid site_url" do
      it "does not set errors" do
        record = generic_model_class.new(site_url: "https://example.com/")

        validator = described_class.new(attributes: [:site_url])
        validator.validate(record)

        assert_not(record.errors.of_kind?(:site_url))
      end
    end
  end

  def generic_model_class
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.name
        "GenericModelClass"
      end

      attribute :site_url
      attribute :other
    end
  end
end
