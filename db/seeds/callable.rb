# frozen_string_literal: true

module Seeds
  module Callable
    module DevelopmentOnly
      def call
        return unless Rails.env.development?

        super
      end
    end

    extend ActiveSupport::Concern

    class_methods do
      def call(...)
        new(...).call
      end
    end

    included do
      prepend DevelopmentOnly
    end
  end
end
