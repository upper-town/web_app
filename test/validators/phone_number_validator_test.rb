# frozen_string_literal: true

require "test_helper"

class PhoneNumberValidatorTest < ActiveSupport::TestCase
  let(:described_class) { PhoneNumberValidator }

  describe "#validate" do
    describe "when record has an invalid phone number" do
      it "sets record.errors" do
        record = generic_model_class.new(phone_number: "abcdef")

        validator = described_class.new(attributes: [:phone_number])
        validator.validate(record)

        assert(record.errors.of_kind?(:phone_number, :invalid))
      end
    end

    describe "when record has a blank phone number" do
      it "does not set errors" do
        record = generic_model_class.new(phone_number: " ")

        validator = described_class.new(attributes: [:phone_number])
        validator.validate(record)

        assert_not(record.errors.key?(:phone_number))
      end
    end

    describe "when record has a possible phone number" do
      it "does not set errors" do
        record = generic_model_class.new(phone_number: "+1 (202) 555-9999")

        validator = described_class.new(attributes: [:phone_number])
        validator.validate(record)

        assert_not(record.errors.key?(:phone_number))
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

      attribute :phone_number
      attribute :other
    end
  end
end
