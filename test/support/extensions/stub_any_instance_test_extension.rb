# frozen_string_literal: true

# https://github.com/codeodor/minitest-stub_any_instance/blob/master/lib/minitest/stub_any_instance.rb
class BasicObject
  def self.stub_any_instance(name, val_or_callable = nil)
    new_name = "__minitest_any_instance_stub__#{name}"
    owns_method = instance_method(name).owner == self

    class_eval do
      alias_method new_name, name if owns_method

      define_method(name) do |*args, **kwargs|
        if val_or_callable.respond_to?(:call)
          instance_exec(*args, **kwargs, &val_or_callable)
        else
          val_or_callable
        end
      end
    end

    yield
  ensure
    class_eval do
      remove_method name

      if owns_method
        alias_method name, new_name
        remove_method new_name
      end
    end
  end
end
