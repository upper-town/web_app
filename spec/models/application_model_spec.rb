require 'rails_helper'

RSpec.describe ApplicationModel do
  it 'accepts attributes with type and default' do
    model_class = Class.new(ApplicationModel) do
      attribute :name, :string, default: ''
      attribute :age, :integer, default: nil
      attribute :amount, :float, default: 0.00
    end

    instance = model_class.new
    expect(instance.name).to eq('')
    expect(instance.age).to be_nil
    expect(instance.amount).to eq(0.00)

    instance.name = 'John'
    instance.age = '42'
    instance.amount = '10.99'
    expect(instance.name).to eq('John')
    expect(instance.age).to eq(42)
    expect(instance.amount).to eq(10.99)

    instance = model_class.new(name: 'John', age: '42', amount: '10.99')
    expect(instance.name).to eq('John')
    expect(instance.age).to eq(42)
    expect(instance.amount).to eq(10.99)
    expect(instance.attributes).to eq({
      'name' => 'John',
      'age' => 42,
      'amount' => 10.99
    })
  end

  it 'serializes to JSON' do
    model_class = Class.new(ApplicationModel) do
      attribute :name, :string, default: ''
      attribute :age, :integer, default: nil
      attribute :amount, :float, default: 0.00
    end
    instance = model_class.new(name: 'John', age: '42', amount: '10.99')

    expect(instance.to_json).to eq('{"name":"John","age":42,"amount":10.99}')
  end

  it 'has access to NumberHelper methods' do
    model_class = Class.new(ApplicationModel) do
      attribute :amount, :float, default: 0.00

      def formatted_amount
        number_to_currency(amount)
      end
    end
    instance = model_class.new(amount: '10.99')

    expect(instance.formatted_amount).to eq('$10.99')
  end

  it 'has access to application routes methods' do
    model_class = Class.new(ApplicationModel) do
      def some_url
        root_url
      end
    end
    instance = model_class.new

    expect(instance.some_url).to eq("http://#{ENV.fetch('APP_HOST')}:#{ENV.fetch('APP_PORT')}/")
  end

  it 'equals by attributes' do
    model_class = Class.new(ApplicationModel) do
      attribute :name, :string, default: ''
      attribute :age, :integer, default: nil
      attribute :amount, :float, default: 0.00
    end
    instance = model_class.new(name: 'John', age: '42', amount: '10.99')

    other_instance = model_class.new(name: 'John', age: 42, amount: 10.99)
    expect(instance == other_instance).to be(true)

    other_instance.name = 'Jane'
    expect(instance == other_instance).to be(false)
  end

  it 'equals by id' do
    model_class = Class.new(ApplicationModel) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ''
    end
    instance = model_class.new(id: 111, name: 'John')

    other_instance = model_class.new(id: 111, name: 'Jane')
    expect(instance == other_instance).to be(true)

    other_instance.id = 222
    expect(instance == other_instance).to be(false)
  end

  it 'must be of the same class to be equal' do
    model_class = Class.new(ApplicationModel) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ''
    end
    other_model_class = Class.new(ApplicationModel) do
      attribute :id, :integer, default: nil
      attribute :name, :string, default: ''
    end

    instance = model_class.new(id: 111, name: 'John')
    other_instance = other_model_class.new(id: 111, name: 'John')

    expect(instance == other_instance).to be(false)
  end
end
