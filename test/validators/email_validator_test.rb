# frozen_string_literal: true

require "test_helper"

class EmailValidatorTest < ActiveSupport::TestCase
  let(:described_class) { EmailValidator }

  describe "#validate" do
    describe "when record has an invalid email" do
      it "sets record.errors" do
        record = generic_model_class.new(email: "abcdef")

        validator = described_class.new(attributes: [:email])
        validator.validate(record)

        assert(record.errors.of_kind?(:email, :format_is_not_valid))
      end
    end

    describe "when record has an unsupported email" do
      it "sets record.errors" do
        record = generic_model_class.new(email: "user@example.com")

        validator = described_class.new(attributes: [:email])
        validator.validate(record)

        assert(record.errors.of_kind?(:email, :domain_is_not_supported))
      end
    end

    describe "when record has a blank email" do
      it "does not set errors" do
        record = generic_model_class.new(email: " ")

        validator = described_class.new(attributes: [:email])
        validator.validate(record)

        assert_not(record.errors.key?(:email))
      end
    end

    describe "when record has a valid email" do
      it "does not set errors" do
        record = generic_model_class.new(email: "user@upper.town")

        validator = described_class.new(attributes: [:email])
        validator.validate(record)

        assert_not(record.errors.key?(:email))
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

      attribute :email
      attribute :other
    end
  end
end
