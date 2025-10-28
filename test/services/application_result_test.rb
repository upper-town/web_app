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

  describe "#add_error" do
    it "adds to errors from Symbol" do
      [
        [:some_error, nil,             { some_error: ["is invalid"] }],
        [:some_error, :invalid,        { some_error: ["is invalid"] }],
        [:some_error, "error message", { some_error: ["error message"] }],
        [:"",         "error message", {}]
      ].each do |value, type, expected_errors_messages|
        result = described_class.new
        result.add_error(value, type)

        assert_equal(expected_errors_messages, result.errors.messages)
      end
    end

    it "adds to errors from Numeric" do
      [
        [0,   nil,             { "0":   ["is invalid"] }],
        [42,  :invalid,        { "42":  ["is invalid"] }],
        [100, "error message", { "100": ["error message"] }],
      ].each do |value, type, expected_errors_messages|
        result = described_class.new
        result.add_error(value, type)

        assert_equal(expected_errors_messages, result.errors.messages)
      end
    end

    it "adds to errors from String" do
      [
        ["error message", nil,            { base: ["error message"] }],
        ["error message", :ignored_type,  { base: ["error message"] }],
        ["error message", "ignored type", { base: ["error message"] }],
        ["",              "ignored type", {}],
      ].each do |value, type, expected_errors_messages|
        result = described_class.new
        result.add_error(value, type)

        assert_equal(expected_errors_messages, result.errors.messages)
      end
    end

    it "adds to errors from ActiveModel::Errors" do
      active_model_errors = ActiveModel::Errors.new(generic_model_class.new)
      active_model_errors.add(:name, "error message")
      active_model_errors.add(:description, :invalid)

      result = described_class.failure("existing error message")
      result.add_error(active_model_errors)

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

    it "adds to errors from StandardError" do
      result = described_class.new
      result.add_error(StandardError.new("error message"))

      assert(result.errors.of_kind?(:base, "StandardError: error message"))
      assert_equal({ base: ["StandardError: error message"] }, result.errors.messages)
    end

    it "adds to errors from true with default error" do
      result = described_class.new
      result.add_error(true)

      assert(result.errors.of_kind?(:base, :invalid))
      assert_equal({ base: ["is invalid"] }, result.errors.messages)
    end

    it "does not add to errors from nil, false" do
      [nil, false].each do |value|
        result = described_class.new
        result.add_error(value)

        assert_empty(result.errors)
      end
    end

    it "raises an error when errors class is invalid" do
      error = assert_raises(StandardError) do
        result = described_class.new
        result.add_error(Time.current)
      end

      assert_match(
        /ApplicationResult: invalid class for error/,
        error.message
      )
    end
  end

  describe ".success" do
    it "creates an instance with empty errors" do
      result = described_class.success

      assert_empty(result.errors)
    end

    it "accepts data" do
      result = generic_result_class.success(attr: "value")

      assert_empty(result.errors)
      assert_equal("value", result.attr)
    end
  end

  describe ".failure" do
    it "ensures a Result instance is created with errors, defaults to a generic error" do
      result = described_class.failure(nil, nil)

      assert(result.errors.of_kind?(:base, :invalid))
      assert_equal({ base: ["is invalid"] }, result.errors.messages)
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
