# frozen_string_literal: true

require "test_helper"

class ApplicationModelTest < ActiveSupport::TestCase
  let(:described_class) { ApplicationModel }

  it "accepts attributes with type and default" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
      attribute :age, :integer, default: nil
      attribute :amount, :float, default: 0.00
    end

    instance = model_class.new
    assert_equal("", instance.name)
    assert_nil(instance.age)
    assert_equal(0.00, instance.amount)

    instance.name = "John"
    instance.age = "42"
    instance.amount = "10.99"
    assert_equal("John", instance.name)
    assert_equal(42, instance.age)
    assert_equal(10.99, instance.amount)

    instance = model_class.new(name: "John", age: "42", amount: "10.99")
    assert_equal("John", instance.name)
    assert_equal(42, instance.age)
    assert_equal(10.99, instance.amount)
    assert_equal(
      {
        "name" => "John",
        "age" => 42,
        "amount" => 10.99
      },
      instance.attributes
    )
  end

  it "serializes to JSON" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
      attribute :age, :integer, default: nil
      attribute :amount, :float, default: 0.00
    end
    instance = model_class.new(name: "John", age: "42", amount: "10.99")

    assert_equal(
      '{"name":"John","age":42,"amount":10.99}',
      instance.to_json
    )
  end

  it "has access to NumberHelper methods" do
    model_class = Class.new(described_class) do
      attribute :amount, :float, default: 0.00

      def formatted_amount
        number_to_currency(amount)
      end
    end
    instance = model_class.new(amount: "10.99")

    assert_equal("$10.99", instance.formatted_amount)
  end

  it "has access to application routes methods" do
    model_class = Class.new(described_class) do
      def some_url
        root_url
      end
    end
    instance = model_class.new

    assert_equal(
      "http://#{AppUtil.webapp_host}:#{AppUtil.webapp_port}/",
      instance.some_url
    )
  end

  it "equals by attributes" do
    model_class = Class.new(described_class) do
      attribute :name, :string, default: ""
      attribute :age, :integer, default: nil
      attribute :amount, :float, default: 0.00
    end
    instance = model_class.new(name: "John", age: "42", amount: "10.99")

    other_instance = model_class.new(name: "John", age: 42, amount: 10.99)
    assert(instance == other_instance)

    other_instance.name = "Jane"
    assert_not(instance == other_instance)
  end

  it "equals by id" do
    model_class = Class.new(described_class) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ""
    end
    instance = model_class.new(id: 111, name: "John")

    other_instance = model_class.new(id: 111, name: "Jane")
    assert(instance == other_instance)

    other_instance.id = 222
    assert_not(instance == other_instance)
  end

  it "must be of the same class to be equal" do
    model_class = Class.new(described_class) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ""
    end
    other_model_class = Class.new(described_class) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ""
    end

    instance = model_class.new(id: 111, name: "John")
    other_instance = other_model_class.new(id: 111, name: "John")

    assert_not(instance == other_instance)
  end
end
