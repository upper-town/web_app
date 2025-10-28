# frozen_string_literal: true

module ApplicationRecordTestFactoryHelper
  def self.define(name, model, **basic_attributes)
    define_method("build_#{name}") do |**attributes|
      basic_attributes.each do |attr_name, attr_proc|
        next if attributes.key?(attr_name)

        attributes[attr_name] = if attr_proc.arity.zero?
          instance_exec(&attr_proc)
        else
          instance_exec(attributes, &attr_proc)
        end
      end

      model.new(**attributes)
    end

    define_method("create_#{name}") do |**attributes|
      public_send("build_#{name}", **attributes).tap { it.save! }
    end
  end
end
