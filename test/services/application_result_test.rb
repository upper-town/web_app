# frozen_string_literal: true

require "test_helper"

class ApplicationResultTest < ActiveSupport::TestCase
  let(:described_class) { ApplicationResult }

  describe "#success?" do
    it "returns true when #errors is empty" do
      result = described_class.new

      assert_empty(result.errors)
      assert(result.success?)
    end

    it "returns false when #errors is not empty" do
      result = described_class.failure("error message")

      assert_not_empty(result.errors)
      assert_not(result.success?)
    end
  end

  describe "#failure?" do
    it "returns true when #errors is not empty" do
      result = described_class.failure("error message")

      assert_not_empty(result.errors)
      assert(result.failure?)
    end

    it "returns false when #errors is empty" do
      result = described_class.new

      assert_empty(result.errors)
      assert_not(result.failure?)
    end
  end

  describe "#add_errors" do
    it "adds to errors from Hash with Symbol, String, Number or Array values, and skips blanks" do
      result = described_class.failure("existing error message")

      result.add_errors(
        {
          error_code_1: "error message",
          error_code_2: :invalid,
          error_code_3: 123456,
          error_code_4: " ",
          error_code_5: false,
          error_code_6: nil,
          error_code_7: [],
          error_code_8: ["error message", :invalid, 123456, " ", false, nil]
        }
      )

      assert(result.errors.of_kind?(:base, "existing error message"))
      assert(result.errors.of_kind?(:error_code_1, "error message"))
      assert(result.errors.of_kind?(:error_code_2, :invalid))
      assert(result.errors.of_kind?(:error_code_3, "123456"))
      assert(result.errors.of_kind?(:error_code_8, "error message"))
      assert(result.errors.of_kind?(:error_code_8, :invalid))
      assert(result.errors.of_kind?(:error_code_8, "123456"))
      assert_equal(
        {
          base: ["existing error message"],
          error_code_1: ["error message"],
          error_code_2: ["is invalid"],
          error_code_3: ["123456"],
          error_code_8: ["error message", "is invalid", "123456"]
        },
        result.errors.messages
      )
    end

    it "adds to errors from Array, and skips blanks" do
      result = described_class.failure("existing error message")

      result.add_errors(
        ["error message", :invalid, 123456, " ", false, nil]
      )

      assert(result.errors.of_kind?(:base, "existing error message"))
      assert(result.errors.of_kind?(:base, "error message"))
      assert(result.errors.of_kind?(:base, :invalid))
      assert(result.errors.of_kind?(:base, "123456"))
      assert_equal(
        { base: ["existing error message", "error message", "is invalid", "123456"] },
        result.errors.messages
      )
    end

    it "adds to errors from String, Symbol, Numeric, and skips blanks" do
      [
        ["error message", ["existing error message", "error message"], { base: ["existing error message", "error message"] }],
        [:invalid,        ["existing error message", :invalid],        { base: ["existing error message", "is invalid"] }],
        [123456,          ["existing error message", "123456"],        { base: ["existing error message", "123456"]  }],
        [1234.56,         ["existing error message", "1234.56"],       { base: ["existing error message", "1234.56"] }]
      ].each do |error_value, expected_error_types, expected_error_messages|
        result = described_class.failure("existing error message")

        result.add_errors(error_value)

        expected_error_types.each do |expected_type|
          assert(result.errors.of_kind?(:base, expected_type), "Failed for #{error_value.inspect}")
        end
        assert_equal(expected_error_messages, result.errors.messages)
      end

      [" ", "", :'', false, nil].each do |blank_error_value|
        result = described_class.failure("existing error message")

        result.add_errors(blank_error_value)

        assert(result.errors.of_kind?(:base, "existing error message"), "Failed for #{blank_error_value.inspect}")
        assert_equal({ base: ["existing error message"] }, result.errors.messages)
      end
    end

    it "adds to errors from ActiveModel::Errors" do
      active_model_errors = ActiveModel::Errors.new(generic_model_class.new)
      active_model_errors.add(:name, "error message")
      active_model_errors.add(:description, :invalid)

      result = described_class.failure("existing error message")

      result.add_errors(active_model_errors)

      assert(result.errors.of_kind?(:base, "existing error message"))
      assert(result.errors.of_kind?(:name, "error message"))
      assert(result.errors.of_kind?(:description, :invalid))
      assert_equal(
        {
          base: ["existing error message"],
          name: ["error message"],
          description: ["is invalid"]
        },
        result.errors.messages
      )
    end

    it "adds to errors from true with a generic message" do
      result = described_class.failure("existing error message")

      result.add_errors(true)

      assert(result.errors.of_kind?(:base, :generic_error))
      assert(result.errors.of_kind?(:base, "existing error message"))
      assert_equal(
        { base: ["existing error message", "An error has occurred"] },
        result.errors.messages
      )
    end

    it "does not add to errors from nil, false" do
      [nil, false].each do |nil_or_false_error_value|
        result = described_class.failure("existing error message")

        result.add_errors(nil_or_false_error_value)

        assert(result.errors.of_kind?(:base, "existing error message"), "Failed for #{nil_or_false_error_value.inspect}")
        assert_equal(
          { base: ["existing error message"] },
          result.errors.messages
        )
      end
    end

    it "raises an error when errors class is invalid" do
      error = assert_raises(StandardError) do
        result = described_class.failure("existing error message")
        result.add_errors(Time.current)
      end

      assert_match(
        /ApplicationResult: invalid error_values\.class/,
        error.message
      )
    end
  end

  describe ".success" do
    it "creates an instance with empty errors and empty data" do
      result = described_class.success

      assert_empty(result.errors)
    end

    it "accepts only data" do
      result = generic_result_class.success(attr: "value")

      assert_empty(result.errors)
      assert_equal("value", result.attr)
    end
  end

  describe ".failure" do
    it "ensures a Result instance is created with errors, defaults to a generic error" do
      result = described_class.failure(nil)

      assert(result.errors.of_kind?(:base, :generic_error))
      assert_equal({ base: ["An error has occurred"] }, result.errors.messages)
    end

    it "accepts errors and data" do
      result = generic_result_class.failure("error message", attr: "value")

      assert(result.errors.of_kind?(:base, "error message"))
      assert_equal({ base: ["error message"] }, result.errors.messages)
      assert_equal("value", result.attr)
    end
  end

  def generic_model_class
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.name
        "GenericModelClass"
      end

      attribute :name
      attribute :description
    end
  end

  def generic_result_class
    Class.new(described_class) do
      attribute :attr
    end
  end
end
