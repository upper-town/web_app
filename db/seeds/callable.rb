# frozen_string_literal: true

module Seeds
  module Callable
    extend ActiveSupport::Concern

    class_methods do
      def call(...)
        new(...).call
      end
    end

    def call
      return unless Rails.env.development?

      super
    end
  end
end
